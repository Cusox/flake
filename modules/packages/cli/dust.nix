{
  flake.modules.packages = {
    homeManager.dust =
      { pkgs, ... }:
      {
        home.packages = [
          pkgs.dust
        ];
      };
  };
}
