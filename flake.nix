{
  description = "A complete and Simple Nixos Mailserver";

  inputs = {
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "flake:nixpkgs/nixos-unstable";
    blobs = {
      url = "gitlab:simple-nixos-mailserver/blobs";
      flake = false;
    };
  };

  outputs = { self, utils, blobs, nixpkgs, ... }: let
    lib = nixpkgs.lib;
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    releases = [
      {
        name = "unstable";
        pkgs = nixpkgs.legacyPackages.${system};
      }
    ];
    testNames = [
      "internal"
      "external"
      "clamav"
      "multiple"
      "ldap"
    ];
    genTest = testName: release: {
      "name"= "${testName}-${builtins.replaceStrings ["."] ["_"] release.name}";
      "value"= import (./tests/. + "/${testName}.nix") {
        pkgs = release.pkgs;
        inherit blobs;
      };
    };
    # Generate an attribute set such as
    # {
    #   external-unstable = <derivation>;
    #   external-21_05 = <derivation>;
    #   ...
    # }
    allTests = lib.listToAttrs (
      lib.flatten (map (t: map (r: genTest t r) releases) testNames));

    mailserverModule = import ./.;

    # Generate a MarkDown file describing the options of the NixOS mailserver module
    optionsDoc = let
      eval = lib.evalModules {
        modules = [
          mailserverModule
          {
            _module.check = false;
            mailserver = {
              fqdn = "mx.example.com";
              domains = [
                "example.com"
              ];
              dmarcReporting = {
                organizationName = "Example Corp";
                domain = "example.com";
              };
            };
          }
        ];
      };
      options = builtins.toFile "options.json" (builtins.toJSON
        (lib.filter (opt: opt.visible && !opt.internal && lib.head opt.loc == "mailserver")
          (lib.optionAttrSetToDocList eval.options)));
    in pkgs.runCommand "options.md" { buildInputs = [pkgs.python3Minimal]; } ''
      echo "Generating options.md from ${options}"
      python ${./scripts/generate-options.py} ${options} > $out
    '';

    documentation = pkgs.stdenv.mkDerivation {
      name = "documentation";
      src = lib.sourceByRegex ./docs ["logo\\.png" "conf\\.py" "Makefile" ".*\\.rst"];
      buildInputs = [(
        pkgs.python3.withPackages (p: with p; [
          sphinx
          sphinx_rtd_theme
          myst-parser
          linkify-it-py
        ])
      )];
      buildPhase = ''
        cp ${optionsDoc} options.md
        # Workaround for https://github.com/sphinx-doc/sphinx/issues/3451
        unset SOURCE_DATE_EPOCH
        make html
      '';
      installPhase = ''
        cp -Tr _build/html $out
      '';
    };

  in {
    nixosModules = rec {
      mailserver = mailserverModule;
      default = mailserver;
    };
    nixosModule = self.nixosModules.default; # compatibility
    hydraJobs.${system} = allTests // {
      inherit documentation;
    };
    checks.${system} = allTests;
    packages.${system} = {
      inherit optionsDoc documentation;
    };
    devShells.${system}.default = pkgs.mkShell {
      inputsFrom = [ documentation ];
      packages = with pkgs; [
        clamav
      ];
    };
    devShell.${system} = self.devShells.${system}.default; # compatibility
  };
}
