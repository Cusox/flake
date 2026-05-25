{
  inputs,
  hosts,
  modules ? [ ],
  overlays ? [ ],
  ...
}:
let
  nixpkgs = inputs.nixpkgs;
  lib = nixpkgs.lib;

  hostConfigPath = (import ../../modules/hostenv.nix).checkHostConfigPath;

  mkVPSHost =
    hostName: host:
    let
      system = host.arch;

      specialArgs = {
        inherit inputs hostName;
        user = host.user;
        hostConfig = import "${hostConfigPath}/${hostName}.nix";
        homeModule = ./${hostName}/home.nix;
      };
    in
    lib.nixosSystem {
      inherit system specialArgs;

      modules = [
        ./${hostName}

        {
          nixpkgs.overlays = overlays;
        }
      ]
      ++ modules;
    };
in
lib.mapAttrs mkVPSHost hosts
