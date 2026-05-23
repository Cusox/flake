{ user, ... }:

let
  username = user.username;
in
{
  imports = [
    ../../../home/recipes/minimal

    ../../../modules/home/ssh-keys.nix
  ];

  home = {
    inherit username;

    homeDirectory = "/home/${username}";

    stateVersion = "26.05";
  };

  programs.home-manager.enable = true;
}
