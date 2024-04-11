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

{ config, pkgs, lib }:

let
  cfg = config.mailserver;
in
{
  # cert :: PATH
  certificatePath = if cfg.certificateScheme == "manual"
             then cfg.certificateFile
             else if cfg.certificateScheme == "selfsigned"
                  then "${cfg.certificateDirectory}/cert-${cfg.fqdn}.pem"
                  else if cfg.certificateScheme == "acme" || cfg.certificateScheme == "acme-nginx"
                       then "${config.security.acme.certs.${cfg.fqdn}.directory}/fullchain.pem"
                       else throw "unknown certificate scheme";

  # key :: PATH
  keyPath = if cfg.certificateScheme == "manual"
        then cfg.keyFile
        else if cfg.certificateScheme == "selfsigned"
             then "${cfg.certificateDirectory}/key-${cfg.fqdn}.pem"
              else if cfg.certificateScheme == "acme" || cfg.certificateScheme == "acme-nginx"
                   then "${config.security.acme.certs.${cfg.fqdn}.directory}/key.pem"
                   else throw "unknown certificate scheme";

  passwordFiles = let
    mkHashFile = name: hash: pkgs.writeText "${builtins.hashString "sha256" name}-password-hash" hash;
  in
    lib.mapAttrs (name: value:
    if value.hashedPasswordFile == null then
      builtins.toString (mkHashFile name value.hashedPassword)
    else value.hashedPasswordFile) cfg.loginAccounts;

  # Appends the LDAP bind password to files to avoid writing this
  # password into the Nix store.
  appendLdapBindPwd = {
    name, file, prefix, passwordFile, destination
  }: pkgs.writeScript "append-ldap-bind-pwd-in-${name}" ''
    #!${pkgs.stdenv.shell}
    set -euo pipefail

    baseDir=$(dirname ${destination})
    if (! test -d "$baseDir"); then
      mkdir -p $baseDir
      chmod 755 $baseDir
    fi

    cat ${file} > ${destination}
    echo -n "${prefix}" >> ${destination}
    cat ${passwordFile} >> ${destination}
    chmod 600 ${destination}
  '';

}
