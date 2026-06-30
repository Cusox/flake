{
  flake.modules.packages = {
    homeManager.pay-respects = {
      programs.pay-respects = {
        enable = true;
        enableZshIntegration = true;
      };
    };
  };
}
