{
  flake.modules.packages = {
    homeManager.git = {
      programs.git = {
        enable = true;
        signing = {
          key = null;
          format = null;
          signByDefault = null;
          signer = null;
        };
        settings = import ./_settings.nix;
      };

      programs.git-credential-oauth = {
        enable = true;
        extraFlags = [ "-device" ];
      };
    };
  };
}
