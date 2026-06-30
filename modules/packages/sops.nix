{
  flake.modules.packages = {
    homeManager.sops =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          age
          sops
        ];
      };
  };
}
