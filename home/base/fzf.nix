{
  programs.fzf = {
    enable = true;

    defaultOptions = [
      "--height 40%"
      "--border"
    ];

    enableZshIntegration = true;
  };
}
