{ config, pkgs, ... }:

{
  general = {
    import = [
      "${config.home.homeDirectory}/.config/alacritty/themes/nordic.toml"
    ];
  };

  window = {
    dynamic_padding = true;
    startup_mode = "Maximized";
    dynamic_title = false;
  };

  scrolling = {
    history = 100000;
  };

  font = {
    normal = {
      family = "Maple Mono NF CN";
      style = "Regular";
    };

    size = 14;
  };

  colors = {
    draw_bold_text_with_bright_colors = true;
  };

  selection = {
    save_to_clipboard = true;
  };

  cursor = {
    style = {
      shape = "Beam";
      blinking = "Always";
    };

    vi_mode_style = {
      shape = "Block";
      blinking = "Never";
    };
  };

  terminal = {
    shell = {
      program = "${pkgs.zsh}/bin/zsh";
      args = [ "--login" ];
    };
  };

  mouse = {
    hide_when_typing = true;

    bindings = [
      {
        mouse = "Right";
        action = "Copy";
      }
    ];
  };

  keyboard = {
    bindings = [
      {
        key = "V";
        mods = "Control";
        mode = "~Vi";
        action = "Paste";
      }
      {
        key = "N";
        mods = "Control";
        mode = "~Vi";
        action = "CreateNewWindow";
      }
    ];
  };
}
