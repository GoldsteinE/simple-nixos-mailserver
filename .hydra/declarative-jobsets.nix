{ nixpkgs, pulls, ... }:

let
  pkgs = import nixpkgs {};

  prs = builtins.fromJSON (builtins.readFile pulls);
  prJobsets =  pkgs.lib.mapAttrs (num: info:
    { enabled = 1;
      hidden = false;
      description = "PR ${num}: ${info.title}";
      checkinterval = 30;
      schedulingshares = 20;
      enableemail = false;
      emailoverride = "";
      keepnr = 1;
      type = 1;
      flake = "gitlab:simple-nixos-mailserver/nixos-mailserver/merge-requests/${info.iid}/head";
    }
  ) prs;
  mkFlakeJobset = branch: {
    description = "Build ${branch} branch of Simple NixOS MailServer";
    checkinterval = "60";
    enabled = "1";
    schedulingshares = 100;
    enableemail = false;
    emailoverride = "";
    keepnr = 3;
    hidden = false;
    type = 1;
    flake = "gitlab:simple-nixos-mailserver/nixos-mailserver/${branch}";
  };

  desc = prJobsets // {
    "master" = mkFlakeJobset "master";
    "nixos-23.05" = mkFlakeJobset "nixos-23.05";
    "nixos-23.11" = mkFlakeJobset "nixos-23.11";
  };

  log = {
    pulls = prs;
    jobsets = desc;
  };

in {
  jobsets = pkgs.runCommand "spec-jobsets.json" {} ''
    cat >$out <<EOF
    ${builtins.toJSON desc}
    EOF
    # This is to get nice .jobsets build logs on Hydra
    cat >tmp <<EOF
    ${builtins.toJSON log}
    EOF
    ${pkgs.jq}/bin/jq . tmp
  '';
}
