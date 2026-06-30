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
  home-manager = inputs.home-manager;

  mkHomeHost =
    hostName: host:
    let
      system = host.arch;

      pkgs = import inputs.nixpkgs {
        inherit system;

        overlays = overlays;
      };

      extraSpecialArgs = {
        inherit inputs hostName hosts;
        user = host.user;
      };
    in
    home-manager.lib.homeManagerConfiguration {
      inherit extraSpecialArgs pkgs;

      modules = [
        ./${hostName}/home.nix
      ]
      ++ modules;
    };
in
lib.mapAttrs mkHomeHost hosts
