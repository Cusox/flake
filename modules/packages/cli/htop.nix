{
  flake.modules.packages = {
    homeManager.htop = {
      programs.htop = {
        enable = true;
      };
    };
  };
}
