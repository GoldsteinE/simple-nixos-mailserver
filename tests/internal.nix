#  nixos-mailserver: a simple mail server
#  Copyright (C) 2016-2018  Robin Raymond
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program. If not, see <http://www.gnu.org/licenses/>

{ pkgs ? import <nixpkgs> {}, ...}:

let
  sendMail = pkgs.writeTextFile {
    "name" = "send-mail-to-send-only-account";
    "text" = ''
      EHLO mail.example.com
      MAIL FROM: none@example.com
      RCPT TO: send-only@example.com
      QUIT
    '';
  };

  hashPassword = password: pkgs.runCommand
    "password-${password}-hashed"
    { buildInputs = [ pkgs.mkpasswd ]; inherit password; } ''
      mkpasswd -sm bcrypt <<<"$password" > $out
    '';

  hashedPasswordFile = hashPassword "my-password";
  passwordFile = pkgs.writeText "password" "my-password";
in
pkgs.nixosTest {
  name = "internal";
  nodes = {
    machine = { config, pkgs, ... }: {
      imports = [
        ./../default.nix
        ./lib/config.nix
      ];

      virtualisation.memorySize = 1024;

      environment.systemPackages = [
        (pkgs.writeScriptBin "mail-check" ''
          ${pkgs.python3}/bin/python ${../scripts/mail-check.py} $@
        '')];

      mailserver = {
        enable = true;
        fqdn = "mail.example.com";
        domains = [ "example.com" "domain.com" ];
        localDnsResolver = false;

        loginAccounts = {
          "user1@example.com" = {
            hashedPasswordFile = hashedPasswordFile;
          };
          "user2@example.com" = {
            hashedPasswordFile = hashedPasswordFile;
            aliasesRegexp = [''/^user2.*@domain\.com$/''];
          };
          "send-only@example.com" = {
            hashedPasswordFile = hashPassword "send-only";
            sendOnly = true;
          };
        };
        forwards = {
          # user2@example.com is a local account and its mails are
          # also forwarded to user1@example.com
          "user2@example.com" = "user1@example.com";
        };

        vmailGroupName = "vmail";
        vmailUID = 5000;

        enableImap = false;
      };
    };
  };
  testScript = ''
    machine.start()
    machine.wait_for_unit("multi-user.target")

    # Regression test for https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/issues/205
    with subtest("mail forwarded can are locally kept"):
        # A mail sent to user2@example.com is in the user1@example.com mailbox
        machine.succeed(
            " ".join(
                [
                    "mail-check send-and-read",
                    "--smtp-port 587",
                    "--smtp-starttls",
                    "--smtp-host localhost",
                    "--imap-host localhost",
                    "--imap-username user1@example.com",
                    "--from-addr user1@example.com",
                    "--to-addr user2@example.com",
                    "--src-password-file ${passwordFile}",
                    "--dst-password-file ${passwordFile}",
                    "--ignore-dkim-spf",
                ]
            )
        )
        # A mail sent to user2@example.com is in the user2@example.com mailbox
        machine.succeed(
            " ".join(
                [
                    "mail-check send-and-read",
                    "--smtp-port 587",
                    "--smtp-starttls",
                    "--smtp-host localhost",
                    "--imap-host localhost",
                    "--imap-username user2@example.com",
                    "--from-addr user1@example.com",
                    "--to-addr user2@example.com",
                    "--src-password-file ${passwordFile}",
                    "--dst-password-file ${passwordFile}",
                    "--ignore-dkim-spf",
                ]
            )
        )

    with subtest("regex email alias are received"):
        # A mail sent to user2-regex-alias@domain.com is in the user2@example.com mailbox
        machine.succeed(
            " ".join(
                [
                    "mail-check send-and-read",
                    "--smtp-port 587",
                    "--smtp-starttls",
                    "--smtp-host localhost",
                    "--imap-host localhost",
                    "--imap-username user2@example.com",
                    "--from-addr user1@example.com",
                    "--to-addr user2-regex-alias@domain.com",
                    "--src-password-file ${passwordFile}",
                    "--dst-password-file ${passwordFile}",
                    "--ignore-dkim-spf",
                ]
            )
        )

    with subtest("user can send from regex email alias"):
        # A mail sent from user2-regex-alias@domain.com, using user2@example.com credentials is received
        machine.succeed(
            " ".join(
                [
                    "mail-check send-and-read",
                    "--smtp-port 587",
                    "--smtp-starttls",
                    "--smtp-host localhost",
                    "--imap-host localhost",
                    "--smtp-username user2@example.com",
                    "--from-addr user2-regex-alias@domain.com",
                    "--to-addr user1@example.com",
                    "--src-password-file ${passwordFile}",
                    "--dst-password-file ${passwordFile}",
                    "--ignore-dkim-spf",
                ]
            )
        )

    with subtest("vmail gid is set correctly"):
        machine.succeed("getent group vmail | grep 5000")

    with subtest("mail to send only accounts is rejected"):
        machine.wait_for_open_port(25)
        # TODO put this blocking into the systemd units
        machine.wait_until_succeeds(
            "set +e; timeout 1 ${pkgs.netcat}/bin/nc -U /run/rspamd/rspamd-milter.sock < /dev/null; [ $? -eq 124 ]"
        )
        machine.succeed(
            "cat ${sendMail} | ${pkgs.netcat-gnu}/bin/nc localhost 25 | grep -q 'This account cannot receive emails'"
        )

    with subtest("rspamd controller serves web ui"):
        machine.succeed(
            "set +o pipefail; ${pkgs.curl}/bin/curl --unix-socket /run/rspamd/worker-controller.sock http://localhost/ | grep -q '<body>'"
        )

    with subtest("imap port 143 is closed and imaps is serving SSL"):
        machine.wait_for_closed_port(143)
        machine.wait_for_open_port(993)
        machine.succeed(
            "echo | ${pkgs.openssl}/bin/openssl s_client -connect localhost:993 | grep 'New, TLS'"
        )
  '';
}
