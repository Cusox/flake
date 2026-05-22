{ pkgs, ... }:

{
  programs.rio = {
    enable = true;

    settings = import ./settings.nix { inherit pkgs; };

    themes = {
      nordic = ./nordic.toml;
    };
  };
}
