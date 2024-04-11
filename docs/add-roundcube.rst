Add Roundcube, a webmail
========================

The NixOS module for roundcube nearly works out of the box with SNM. By
default, it sets up a nginx virtual host to serve the webmail, other web
servers may require more work.

.. code:: nix

   { config, pkgs, lib, ... }:

   with lib;

   {
     services.roundcube = {
        enable = true;
        # this is the url of the vhost, not necessarily the same as the fqdn of
        # the mailserver
        hostName = "webmail.example.com";
        extraConfig = ''
          # starttls needed for authentication, so the fqdn required to match
          # the certificate
          $config['smtp_host'] = "tls://${config.mailserver.fqdn}";
          $config['smtp_user'] = "%u";
          $config['smtp_pass'] = "%p";
        '';
     };

     services.nginx.enable = true;

     networking.firewall.allowedTCPPorts = [ 80 443 ];
   }
