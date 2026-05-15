{ inputs, user, pkgs, ...}:
{
  imports = [
    ../../../home
  ];

  home = {
    username = user.username;

    homeDirectory = "/home/${user.username}";

    stateVersion = "26.05";
  };

  programs.home-manager.enable = true;
}
