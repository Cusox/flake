{
  flake.modules.packages = {
    homeManager.jj = {
      programs.jujutsu = {
        enable = true;

        settings = import ./_settings.nix;
      };
    };
  };
}
