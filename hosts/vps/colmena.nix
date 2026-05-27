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

  colmena = inputs.colmena;

  hostConfigPath = (import ../../modules/hostenv.nix).checkHostConfigPath;

  mkVPSNode =
    hostName: host:
    let
      hostConfig = import "${hostConfigPath}/${hostName}.nix";

      specialArgs = {
        inherit hostName hostConfig;
        user = host.user;
        homeModule = ./${hostName}/home.nix;
      };
    in
    {

      imports = [
        ./${hostName}
      ]
      ++ modules;

      deployment = {
        targetHost = hostConfig.ssh.ip;
        targetUser = "root";
        targetPort = hostConfig.ssh.port;

        privilegeEscalationCommand = [ ];
      };

      _module.args = specialArgs;
    };
in

colmena.lib.makeHive (
  {
    meta = {
      nixpkgs = import nixpkgs {
        system = "x86_64-linux";
        inherit overlays;
      };

      specialArgs = {
        inherit inputs;
      };
    };
  }
  // lib.mapAttrs mkVPSNode hosts
)
