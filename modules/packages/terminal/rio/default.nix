{
  flake.modules.packages = {
    homeManager.rio = {
      programs.rio =
        { pkgs, ... }:
        {
          enable = true;

          settings = import ./_settings.nix { inherit pkgs; };

          themes = {
            nordic = ./nordic.toml;
          };
        };
    };
  };
}
