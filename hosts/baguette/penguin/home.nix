{ user, ... }:

let
  username = user.username;
in
{
  imports = [
    ../../../home/recipes/all

    ../../../home/secrets/ssh_private_config.nix
  ];

  home = {
    inherit username;

    homeDirectory = "/home/${username}";

    stateVersion = "26.05";
  };

  programs.home-manager.enable = true;
}
