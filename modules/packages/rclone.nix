{
  flake.modules.packages = {
    homeManager.rclone = {
      programs.rclone = {
        enable = true;
      };
    };
  };
}
