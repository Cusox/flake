{ inputs, user, pkgs, ...}:
{
  imports = [
    ../../../home
  ];

  home = {
    username = user.username;

    homeDirectory = "/home/${user.username}";

    stateVersion = "25.11";
  };

  programs.home-manager.enable = true;
}
