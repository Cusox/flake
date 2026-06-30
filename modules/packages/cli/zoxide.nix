{
  flake.modules.packages = {
    homeManager.zoxide = {
      programs.zoxide = {
        enable = true;

        options = [
          "--cmd"
          "cd"
        ];

        enableZshIntegration = true;
      };
    };
  };
}
