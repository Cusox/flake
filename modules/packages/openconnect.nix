{
  flake.modules.packages = {
    homeManager.openconnect =
      { pkgs, ... }:
      {
        home.packages = [
          pkgs.openconnect
        ];
      };
  };
}
