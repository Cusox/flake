{
  flake.modules.packages = {
    homeManager.fd = {
      programs.fd = {
        enable = true;
        ignores = [
          ".git/"
          "*.bak"
        ];
      };
    };
  };
}
