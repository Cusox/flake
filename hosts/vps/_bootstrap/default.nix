{
  inputs,
  hosts,
  modules ? [ ],
  overlays ? [ ],
  ...
}:

let
  lib = inputs.nixpkgs.lib;

  hostName = builtins.getEnv "VPS_BOOTSTRAP_HOST";
  checkHostName =
    if hostName == "" then
      throw "VPS_BOOTSTRAP_HOST is empty. Use scripts/build-vps-bootstrap-image.sh <host>."
    else
      hostName;

  hostConfigPath = builtins.getEnv "VPS_BOOTSTRAP_CONFIG";
  checkHostConfigPath =
    if hostConfigPath == "" then
      throw "VPS_BOOTSTRAP_CONFIG is empty. Use scripts/build-vps-bootstrap-image.sh <host>."
    else
      hostConfigPath;

  host = hosts.${checkHostName};
  hostConfig = import checkHostConfigPath;

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
