{ inputs, ... }:
{
  flake.modules = {
    "baguette" = {
      imports = [
        inputs.nixos-crostini.nixosModules.baguette
      ];
    };
  };
}
