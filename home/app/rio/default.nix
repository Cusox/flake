{ pkgs, ... }:

{
  programs.rio = {
    enable = true;

    settings = import ./settings.nix pkgs;

    themes = {
      nordic = ./nordic.toml;
    };
  };
}
