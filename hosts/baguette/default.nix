{
  inputs,
  lib,
  home-manager,
  hosts,
  ...
}:
let
  nixos-crostini = inputs.nixos-crostini;

  mkBaguetteHost =
    name: host:
    let
      system = host.arch;

      specialArgs = {
        inherit inputs;
        hostName = name;
        user = host.user;
      };
    in
    lib.nixosSystem {
      inherit system specialArgs;

      modules = [
        ./${name}
        ./${name}/garcon.nix
        ./${name}/sops.nix

        nixos-crostini.nixosModules.baguette

        {
          nixpkgs.config.allowUnfreePredicate =
            pkg:
            builtins.elem (lib.getName pkg) [
              "copilot-language-server"
            ];
        }

        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = specialArgs;

            users.${host.user.username} = ./${name}/home.nix;
          };
        }
      ];
    };
in
lib.mapAttrs mkBaguetteHost hosts
