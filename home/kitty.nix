{
  home.file.".config/kitty/themes/nordic.conf".source = ../config/kitty/themes/nordic.conf;

  programs.kitty = {
    enable = true;
    font = {
      name = "JuliaMono Nerd Font";
      size = 14;
    };
    enableGitIntegration = true;
    settings = import ../config/kitty/settings.nix;
    keybindings = import ../config/kitty/keybindings.nix;
    extraConfig = ''
      include themes/nordic.conf
    '';
  };
}
