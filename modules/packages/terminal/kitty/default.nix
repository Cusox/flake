{
  flake.modules.packages = {
    homeManager.kitty = {
      programs.kitty = {
        enable = true;
        font = {
          name = "Maple Mono NF CN";
          size = 14;
        };
        enableGitIntegration = true;
        settings = import ./_settings.nix;
        keybindings = import ./_keybindings.nix;
        extraConfig = ''
          include themes/nordic.conf
        '';
      };

      home.file.".config/kitty/themes/nordic.conf".source = ./themes/nordic.conf;
    };
  };
}
