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
    modules = [
      ../modules/nixpkgs.nix
      ../modules/system/minimal
      ../modules/system/ssh-private-config.nix
    ];
  };
  wslHosts = mkHosts {
    type = "wsl";
    path = ./wsl;
    modules = [
      ../modules/nixpkgs.nix
      ../modules/system/minimal
      ../modules/system/ssh-private-config.nix
    ];
  };
  homeHosts = mkHosts {
    type = "home";
    path = ./home;
    modules = [
      ../modules/nixpkgs.nix
      ../modules/home/ssh-private-config.nix
    ];
  };
in
{
  nixosConfigurations = baguetteHosts // wslHosts;
  homeConfigurations = homeHosts;
}
