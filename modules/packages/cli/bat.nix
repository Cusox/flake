{
  flake.modules.packages = {
    homeManager.bat = {
      programs.bat = {
        enable = true;

        config = {
          theme = "Nord";
          italic-text = "always";
          style = "full";
        };
      };
    };
  };
}
