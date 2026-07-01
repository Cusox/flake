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
  nixos-crostini = inputs.nixos-crostini;

  mkBaguetteHost =
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

        nixos-crostini.nixosModules.baguette
      ]
      ++ modules;
    };
in
lib.mapAttrs mkBaguetteHost hosts
