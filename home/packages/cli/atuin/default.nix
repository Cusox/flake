{ config, lib, ... }:

{
  programs.atuin = {
    enable = true;

    enableZshIntegration = true;

    settings = import ./settings.nix;

    themes = {
      nordic = ./themes/nordic.toml;
    };

    daemon = {
      enable = true;
      logLevel = "info";
    };
  };

  programs.zsh.initContent = lib.mkBefore ''
    eval "$(${lib.getExe config.programs.atuin.package} hex init zsh)"
  '';
}
