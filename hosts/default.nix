{ inputs, hosts, ... }:
let
  lib = inputs.nixpkgs.lib;

  systems = [
    "x86_64-linux"
    "aarch64-linux"
  ];

  forAllSystems = lib.genAttrs systems;

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

  mkImage =
    {
      path,
      modules ? [ ],
      overlays ? [ ],
    }:
    import path {
      inherit
        inputs
        hosts
        modules
        overlays
        ;
    };

  baguetteHosts = mkHosts {
    type = "baguette";
    path = ./baguette;
    modules = [
      ../modules/nixpkgs.nix
      ../modules/system/minimal
    ];
  };
  wslHosts = mkHosts {
    type = "wsl";
    path = ./wsl;
    modules = [
      ../modules/nixpkgs.nix
      ../modules/system/minimal
    ];
  };
  vpsHosts = mkHosts {
    type = "vps";
    path = ./vps;
    modules = [
      ../modules/nixpkgs.nix
      (import ../modules/system/boot.nix { devices = [ "/dev/vda" ]; })
      ../modules/system/minimal
    ];
  };
  homeHosts = mkHosts {
    type = "home";
    path = ./home;
    modules = [
      ../modules/nixpkgs.nix
    ];
  };

  vpsBootstrapImage = mkImage {
    path = ./vps/_bootstrap;
    modules = [
      ../modules/nixpkgs.nix
      (import ../modules/system/boot.nix { devices = [ "/dev/vda" ]; })
      ../modules/system/nano
    ];
  };

in
{
  nixosConfigurations = baguetteHosts // wslHosts // vpsHosts;
  homeConfigurations = homeHosts;
  packages = forAllSystems (_system: {
    vps-bootstrap-image = vpsBootstrapImage;
  });
}
