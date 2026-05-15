{ config, lib, ... }:

{
  programs.atuin = {
    enable = true;

    enableZshIntegration = true;

    settings = import ../../config/atuin/settings.nix;

    themes = {
      nordic = ../../config/atuin/themes/nordic.toml;
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
