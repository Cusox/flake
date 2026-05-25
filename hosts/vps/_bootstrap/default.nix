{
  inputs,
  hostName,
  host,
  modules ? [ ],
  overlays ? [ ],
  ...
}:

let
  lib = inputs.nixpkgs.lib;

  hostConfigPath = (import ../../../modules/hostenv.nix).checkHostConfigPath;

  hostConfig = import "${hostConfigPath}/${hostName}.nix";

  system = host.arch;
  user = host.user;

  bootstrap = lib.nixosSystem {
    inherit system;

    specialArgs = {
      inherit
        inputs
        hostName
        hostConfig
        user
        ;
    };

    modules = [
      ./image.nix

      {
        nixpkgs.overlays = overlays;
      }
    ]
    ++ modules;
  };

in
bootstrap.config.system.build.diskoImages
