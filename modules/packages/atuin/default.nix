{ lib, ... }:

{
  flake.modules.packages = {
    homeManager.atuin =
      { config, ... }:
      {
        programs.atuin = {
          enable = true;

          enableZshIntegration = true;

          settings = import ./_settings.nix;

          themes = {
            nordic = ./themes/nordic.toml;
          };

          daemon = {
            enable = true;
            logLevel = "info";
          };
        };

        programs.zsh.initContent = lib.mkBefore ''
          eval "$(${lib.getExe config.programs.atuin.package} pty-proxy init zsh)"
        '';
      };
  };
}
