{
  flake.modules = {
    nixos.homeManager = {
      home-manager = {
        backupFileExtension = "bk";

        useGlobalPkgs = true;
        useUserPackages = true;
      };
    };

    homeManager.homeManager =
      user:
      { ... }:
      {
        home = {
          username = user;
          homeDirectory = "/home/${user}";
          stateVersion = "26.05";
        };

        programs.home-manager.enable = true;
      };
  };
}
