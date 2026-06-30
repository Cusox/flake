{
  flake.modules.packages = {
    homeManager.eza = {
      programs.eza = {
        enable = true;

        enableZshIntegration = true;

        extraOptions = [
          "-h"
        ];

        icons = "always";

        colors = "always";

        git = true;
      };
    };
  };
}
