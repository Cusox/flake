{
  inputs,
  lib,
  home-manager,
  hosts,
  ...
}:
let
  mkHomeHost =
    name: host:
    let

      pkgs = import inputs.nixpkgs {
        system = host.arch;
        config.allowUnfree = true;
      };

      specialArgs = {
        inherit inputs hosts;
        hostName = name;
        user = host.user;
      };
    in
    home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = specialArgs;
      modules = [
        ./${name}/home.nix
      ];
    };
in
lib.mapAttrs mkHomeHost hosts
