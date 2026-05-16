{
  inputs,
  lib,
  home-manager,
  hosts,
  ...
}:
let
  nixos-wsl = inputs.nixos-wsl;

  mkWSLHost =
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

        nixos-wsl.nixosModules.default

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
lib.mapAttrs mkWSLHost hosts
