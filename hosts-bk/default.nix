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
      type,
      path,
      namePrefix,
      modules ? [ ],
      overlays ? [ ],
    }:
    let
      imageHosts = lib.filterAttrs (_: host: host.type == type) hosts;
    in
    lib.mapAttrs' (
      hostName: host:
      lib.nameValuePair "${namePrefix}-${hostName}" (
        import path {
          inherit
            inputs
            hostName
            host
            modules
            overlays
            ;
        }
      )
    ) imageHosts;

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
    type = "vps";
    path = ./vps/_bootstrap;
    namePrefix = "vps-bootstrap-image";
    modules = [
      ../modules/nixpkgs.nix
      (import ../modules/system/boot.nix { devices = [ "/dev/vda" ]; })
      ../modules/system/nano
    ];
  };

  colmenaHive = mkHosts {
    type = "vps";
    path = ./vps/colmena.nix;
    modules = [
      ../modules/nixpkgs.nix
      ../modules/system/minimal
    ];
  };
in
{
  nixosConfigurations = wslHosts // vpsHosts;
  homeConfigurations = homeHosts;
  packages = forAllSystems (_system: vpsBootstrapImage);
  inherit colmenaHive;
}
