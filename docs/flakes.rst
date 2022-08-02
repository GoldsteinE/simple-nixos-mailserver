Nix Flakes
==========

If you're using `flakes <https://nixos.wiki/wiki/Flakes>`__, you can use
the following minimal ``flake.nix`` as an example:

.. code:: nix

   {
     description = "NixOS configuration";

     inputs.simple-nixos-mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver/nixos-20.09";

     outputs = { self, nixpkgs, simple-nixos-mailserver }: {
       nixosConfigurations = {
         hostname = nixpkgs.lib.nixosSystem {
           system = "x86_64-linux";
           modules = [
             simple-nixos-mailserver.nixosModule
             {
               mailserver = {
                 enable = true;
                 # ...
               };
             }
           ];
         };
       };
     };
   }
