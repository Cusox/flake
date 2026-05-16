{ inputs, hosts, ... }@args:
let
  lib = inputs.nixpkgs.lib;

  home-manager = inputs.home-manager;

  baguetteHosts = import ./baguette (
    args
    // {
      inherit lib home-manager;
      hosts = lib.filterAttrs (name: host: host.type == "baguette") hosts;
    }
  );

  wslHosts = import ./wsl (
    args
    // {
      inherit lib home-manager;
      hosts = lib.filterAttrs (name: host: host.type == "wsl") hosts;
    }
  );
in
baguetteHosts // wslHosts
