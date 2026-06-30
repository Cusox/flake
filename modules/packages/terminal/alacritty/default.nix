{ config, ... }:

{
  flake.modules.packages = {
    homeManager.alacritty =
      { pkgs, ... }:
      {
        programs.alacritty = {
          enable = true;
          settings = import ./_settings.nix { inherit config pkgs; };
        };

        home.file.".config/alacritty/themes/nordic.toml".source = ./themes/nordic.toml;
      };
  };
}
