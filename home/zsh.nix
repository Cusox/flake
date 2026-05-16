{ lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    # Tools
    dust
    procs

    # Zsh Plugins
    zsh-fzf-tab
    zsh-vi-mode
    zsh-fast-syntax-highlighting
  ];

  programs.bat = {
    enable = true;

    config = {
      theme = "Nord";
      italic-text = "always";
      style = "full";
    };
  };

  programs.ripgrep = {
    enable = true;
  };

  programs.zsh = {
    enable = true;

    shellAliases = {
      "cat" = "bat";
      "grep" = "rg";
      "ps" = "procs";
    };

    autosuggestion = {
      enable = true;
    };

    sessionVariables = {
      LESSCHARSET = "utf-8";
    };

    initContent = lib.mkMerge [
      ''
        source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
        source ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
      ''
      (lib.mkAfter ''
        source ${pkgs.zsh-fast-syntax-highlighting}/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
      '')
    ];

    history = {
      append = true;
      size = 50000;
      save = 50000;
      ignoreAllDups = true;
      expireDuplicatesFirst = true;
    };
  };
}
