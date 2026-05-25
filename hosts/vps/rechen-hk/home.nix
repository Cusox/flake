{ user, ... }:

let
  username = user.username;
in
{
  imports = [
    ../../../home/recipes/minimal
  ];

  home = {
    inherit username;

    homeDirectory = "/${username}";

    stateVersion = "26.05";
  };

  programs.home-manager.enable = true;
}
