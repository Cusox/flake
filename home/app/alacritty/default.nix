{ config, pkgs, ... }:

{
  home.file.".config/alacritty/themes/nordic.toml".source = ./themes/nordic.toml;

  programs.alacritty = {
    enable = true;
    settings = import ./settings.nix { inherit config pkgs; };
  };
}
