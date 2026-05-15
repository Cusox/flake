{
  programs.zsh = {
    enable = true;

    shellAliases = {
      "cat" = "bat";
      "grep" = "rg";
    };

    syntaxHighlighting = {
      enable = true;

      highlighters = [
        "main"
        "brackets"
        "cursor"
        "root"
      ];
    };

    autosuggestion = {
      enable = true;
    };

    sessionVariables = {
      LESSCHARSET = "utf-8";
    };

    history = {
      append = true;
      size = 50000;
      save = 50000;
      ignoreAllDups = true;
      expireDuplicatesFirst = true;
    };
  };
}
