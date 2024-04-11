{ pkgs ? import <nixpkgs> {}
, ...
}:

let
  bindPassword = "unsafegibberish";
  alicePassword = "testalice";
  bobPassword = "testbob";
in
pkgs.nixosTest {
  name = "ldap";
  nodes = {
    machine = { config, pkgs, ... }: {
      imports = [
        ./../default.nix
        ./lib/config.nix
      ];

      virtualisation.memorySize = 1024;

      services.openssh = {
        enable = true;
        permitRootLogin = "yes";
      };

      environment.systemPackages = [
        (pkgs.writeScriptBin "mail-check" ''
          ${pkgs.python3}/bin/python ${../scripts/mail-check.py} $@
        '')];

      environment.etc.bind-password.text = bindPassword;

      services.openldap = {
        enable = true;
        settings = {
          children = {
            "cn=schema".includes = [
              "${pkgs.openldap}/etc/schema/core.ldif"
              "${pkgs.openldap}/etc/schema/cosine.ldif"
              "${pkgs.openldap}/etc/schema/inetorgperson.ldif"
              "${pkgs.openldap}/etc/schema/nis.ldif"
            ];
            "olcDatabase={1}mdb" = {
              attrs = {
                objectClass = [
                  "olcDatabaseConfig"
                  "olcMdbConfig"
                ];
                olcDatabase = "{1}mdb";
                olcDbDirectory = "/var/lib/openldap/example";
                olcSuffix = "dc=example";
              };
            };
          };
        };
        declarativeContents."dc=example" = ''
          dn: dc=example
          objectClass: domain
          dc: example

          dn: cn=mail,dc=example
          objectClass: organizationalRole
          objectClass: simpleSecurityObject
          objectClass: top
          cn: mail
          userPassword: ${bindPassword}

          dn: ou=users,dc=example
          objectClass: organizationalUnit
          ou: users

          dn: cn=alice,ou=users,dc=example
          objectClass: inetOrgPerson
          cn: alice
          sn: Foo
          mail: alice@example.com
          userPassword: ${alicePassword}

          dn: cn=bob,ou=users,dc=example
          objectClass: inetOrgPerson
          cn: bob
          sn: Bar
          mail: bob@example.com
          userPassword: ${bobPassword}
        '';
      };

      mailserver = {
        enable = true;
        fqdn = "mail.example.com";
        domains = [ "example.com" ];
        localDnsResolver = false;

        ldap = {
          enable = true;
          uris = [
            "ldap://"
          ];
          bind = {
            dn = "cn=mail,dc=example";
            passwordFile = "/etc/bind-password";
          };
          searchBase = "ou=users,dc=example";
          searchScope = "sub";
        };

        vmailGroupName = "vmail";
        vmailUID = 5000;

        enableImap = false;
      };
    };
  };
  testScript = ''
    import sys
    import re

    machine.start()
    machine.wait_for_unit("multi-user.target")

    # This function retrieves the ldap table file from a postconf
    # command.
    # A key lookup is achived and the returned value is compared
    # to the expected value.
    def test_lookup(postconf_cmdline, key, expected):
      conf = machine.succeed(postconf_cmdline).rstrip()
      ldap_table_path = re.match('.* =.*ldap:(.*)', conf).group(1)
      value = machine.succeed(f"postmap -q {key} ldap:{ldap_table_path}").rstrip()
      try:
        assert value == expected
      except AssertionError:
        print(f"Expected {conf} lookup for key '{key}' to return '{expected}, but got '{value}'", file=sys.stderr)
        raise

    with subtest("Test postmap lookups"):
      test_lookup("postconf virtual_mailbox_maps", "alice@example.com", "alice@example.com")
      test_lookup("postconf -P submission/inet/smtpd_sender_login_maps", "alice@example.com", "alice@example.com")

      test_lookup("postconf virtual_mailbox_maps", "bob@example.com", "bob@example.com")
      test_lookup("postconf -P submission/inet/smtpd_sender_login_maps", "bob@example.com", "bob@example.com")

    with subtest("Test doveadm lookups"):
      machine.succeed("doveadm user -u alice@example.com")
      machine.succeed("doveadm user -u bob@example.com")

    with subtest("Files containing secrets are only readable by root"):
      machine.succeed("ls -l /run/postfix/*.cf | grep -e '-rw------- 1 root root'")
      machine.succeed("ls -l /run/dovecot2/dovecot-ldap.conf.ext | grep -e '-rw------- 1 root root'")

    with subtest("Test account/mail address binding"):
      machine.fail(" ".join([
        "mail-check send-and-read",
        "--smtp-port 587",
        "--smtp-starttls",
        "--smtp-host localhost",
        "--smtp-username alice@example.com",
        "--imap-host localhost",
        "--imap-username bob@example.com",
        "--from-addr bob@example.com",
        "--to-addr aliceb@example.com",
        "--src-password-file <(echo '${alicePassword}')",
        "--dst-password-file <(echo '${bobPassword}')",
        "--ignore-dkim-spf"
      ]))
      machine.succeed("journalctl -u postfix | grep -q 'Sender address rejected: not owned by user alice@example.com'")

    with subtest("Test mail delivery"):
      machine.succeed(" ".join([
        "mail-check send-and-read",
        "--smtp-port 587",
        "--smtp-starttls",
        "--smtp-host localhost",
        "--smtp-username alice@example.com",
        "--imap-host localhost",
        "--imap-username bob@example.com",
        "--from-addr alice@example.com",
        "--to-addr bob@example.com",
        "--src-password-file <(echo '${alicePassword}')",
        "--dst-password-file <(echo '${bobPassword}')",
        "--ignore-dkim-spf"
      ]))
  '';
}
