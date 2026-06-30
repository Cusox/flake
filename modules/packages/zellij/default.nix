{
  flake.modules.packages = {
    homeManager.zellij = {
      programs.zellij = {
        enable = true;

        extraConfig = builtins.readFile ./config.kdl;
      };
    };
  };
}
