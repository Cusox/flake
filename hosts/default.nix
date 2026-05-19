{ inputs, hosts, ... }@args:
let
  lib = inputs.nixpkgs.lib;

  home-manager = inputs.home-manager;

  mkHosts =
    type: path:
    import path (
      args
      // {
        inherit lib home-manager;
        hosts = lib.filterAttrs (_name: host: host.type == type) hosts;
      }
    );

  baguetteHosts = mkHosts "baguette" ./baguette;
  wslHosts = mkHosts "wsl" ./wsl;
  homeHosts = mkHosts "home" ./home;
in
{
  nixosConfigurations = baguetteHosts // wslHosts;
  homeConfigurations = homeHosts;
}
