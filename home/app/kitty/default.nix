{
  home.file.".config/kitty/themes/nordic.conf".source = ./themes/nordic.conf;

  programs.kitty = {
    enable = true;
    font = {
      name = "Maple Mono NF CN";
      size = 14;
    };
    enableGitIntegration = true;
    settings = import ./settings.nix;
    keybindings = import ./keybindings.nix;
    extraConfig = ''
      include themes/nordic.conf
    '';
  };
}
