{ config, ... }:
let
  modules = [
    "nix"
    "sops"
    "ssh"
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
    "rio-wsl"
    "pi"
  ];
in
{
  flake.nixosConfigurations.omit = config.flake.lib.mkSystem.wsl "omit" "cusox";
  flake.hosts.omit = {
    imports =
      config.flake.lib.loadNixOSAndHMModules config modules "cusox"
      ++ config.flake.lib.loadNixOSAndHMPackages config packages "cusox"
      ++ [
        ./_wsl.nix
        ./_user.nix
      ];
  };
}
