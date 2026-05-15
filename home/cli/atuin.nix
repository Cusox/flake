{
  programs.atuin = {
    enable = true;

    enableZshIntegration = true;

    settings = import ../../config/atuin/settings.nix;

    themes = {
      nordic = ./themes/nordic.toml;
    };

    daemon = {
      enable = true;
      logLevel = "info";
    };
  };
}
