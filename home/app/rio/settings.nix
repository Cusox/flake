{
  pkgs,
  target ? "linux",
  ...
}:
let
  isWindows = target == "windows";
in
{
  copy-on-select = true;

  developer = {
    log-level = "INFO";
    enable-log-file = false;
  };

  editor =
    if isWindows then
      {
        program = "nvim";
        args = [ ];
      }
    else
      {
        program = "${pkgs.neovim}/bin/nvim";
        args = [ ];
      };

  fonts = {
    size = 18;
    family = "JuliaMono Nerd Font";
    use-drawable-chars = true;
  };

  hide-mouse-cursor-when-typing = true;

  window.mode = "Maximized";

  shell = {
    program = "${pkgs.zsh}/bin/zsh";
    args = [ "--login" ];
  };

  theme = "nordic";

  platform = {
    windows = {
      shell = {
        program = "pwsh";
        args = [ "-l" ];
      };
    };
  };
}
