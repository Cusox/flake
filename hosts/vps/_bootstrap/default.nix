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

  hostConfig = import ../../../config/vps/decrypted/${hostName}.nix;

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
