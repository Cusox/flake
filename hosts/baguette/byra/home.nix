{ inputs, user, pkgs, ...}:
{
  imports = [
    ../../../home/fonts.nix
    ../../../home/tui/nixCats
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
