{ pkgs, ... }:

{
  copy-on-select = true;

  developer = {
    log-level = "INFO";
    enable-log-file = false;
  };

  editor = {
    program = "${pkgs.neovim}/bin/nvim";
    args = [ ];
  };

  fonts = {
    size = 16;
    family = "JuliaMono Nerd Font";
    use-drawable-chars = true;
  };

  line-height = 1.5;

  hide-mouse-cursor-when-typing = true;

  window.mode = "Maximized";

  shell = {
    program = "${pkgs.zsh}/bin/zsh";
    args = [ "--login" ];
  };

  theme = "nordic";

  planform = {
    windows = {
      shell = {
        program = "pwsh";
        args = [ "-l" ];
      };
    };
  };
}
