{ config, ... }:
let
  modules = [
    "nix"
    "graphics"
    "sops"
  ];
  packages = [
    "system"
    "fonts"

    "zsh"
    "starship"

    "bat"
    "delta"
    "dust"
    "eza"
    "fastfetch"
    "fd"
    "fzf"
    "htop"
    "procs"
    "ripgrep"
    "zoxide"

    "atuin"
    "git"
    "jj"
    "pay-respects"
    "sops"
    "zellij"

    "nvim"
    "kitty"
    "pi"
  ];
in
{
  flake.nixosConfigurations.penguin = config.flake.lib.mkSystem.baguette "penguin" "chronos";
  flake.hosts.penguin = {
    imports =
      config.flake.lib.loadNixOSAndHMModules config modules "chronos"
      ++ config.flake.lib.loadNixOSAndHMPackages config packages "chronos"
      ++ [
        ./_garcon.nix
        ./_user.nix
      ];
  };
}
