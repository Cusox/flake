{ inputs, user, pkgs, ...}:
{
  imports = [
    ../../../home/cli/nixCats
  ];

  home = {
    username = user.username;
    homeDirectory = "/home/${user.username}";

    packages = with pkgs; [
    ];

    stateVersion = "25.11";
  };

  programs.home-manager.enable = true;
}
