{ inputs, ... }:
{
  flake.modules = {
    baguette = {
      imports = [
        inputs.nixos-crostini.nixosModules.baguette
      ];
    };
    wsl = {
      imports = [
        inputs.nixos-wsl.nixosModules.default
      ];
    };
  };
}
