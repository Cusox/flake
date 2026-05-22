{ user, ... }:

let
  username = user.username;
in
{
  imports = [
    ../../../home/recipes/all
  ];

  home = {
    inherit username;

    homeDirectory = "/home/${username}";

    stateVersion = "26.05";
  };

  programs.home-manager.enable = true;
}
