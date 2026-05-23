{
  user,
  ...
}:
{
  imports = [
    ../../../home/recipes/wsl.nix

    ../../../modules/home/sops.nix
    ../../../modules/home/ssh-private-config.nix
  ];

  home = {
    username = user.username;

    homeDirectory = "/home/${user.username}";

    stateVersion = "26.05";
  };

  programs.home-manager.enable = true;
}
