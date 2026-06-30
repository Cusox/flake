{
  flake.modules.packages = {
    homeManager.procs =
      { pkgs, ... }:
      {
        home.packages = [
          pkgs.procs
        ];
      };
  };
}
