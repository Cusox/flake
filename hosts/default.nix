{ inputs, hosts, ... }:
let
  lib = inputs.nixpkgs.lib;

  mkHosts =
    {
      type,
      path,
      modules ? [ ],
      overlays ? [ ],
    }:
    import path {
      inherit inputs modules overlays;
      hosts = lib.filterAttrs (_: host: host.type == type) hosts;
    };

  baguetteHosts = mkHosts {
    type = "baguette";
    path = ./baguette;
    modules = [ ../modules/system/minimal ];
  };
  wslHosts = mkHosts {
    type = "wsl";
    path = ./wsl;
    modules = [ ../modules/system/minimal ];
  };
  homeHosts = mkHosts {
    type = "home";
    path = ./home;
    modules = [ ../modules/nixpkgs.nix ];
  };
in
{
  nixosConfigurations = baguetteHosts // wslHosts;
  homeConfigurations = homeHosts;
}
