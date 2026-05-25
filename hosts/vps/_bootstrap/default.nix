{
  inputs,
  hosts,
  modules ? [ ],
  overlays ? [ ],
  ...
}:

let
  lib = inputs.nixpkgs.lib;

  hostEnv = import ../../../modules/hostenv.nix;

  hostName = hostEnv.checkHostName;
  hostConfigPath = hostEnv.checkHostName;

  host = hosts.${hostName};
  hostConfig = import hostConfigPath;

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
bootstrap.config.system.build.diskoImage
