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
  nixos-wsl = inputs.nixos-wsl;

  mkWSLHost =
    hostName: host:
    let
      system = host.arch;

      specialArgs = {
        inherit inputs hostName;
        user = host.user;
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

        nixos-wsl.nixosModules.default
      ]
      ++ modules;
    };
in
lib.mapAttrs mkWSLHost hosts
