{ inputs, user, pkgs, ...}:
{
  imports = [
    ../../../home/fonts.nix
    ../../../home/cli/delta.nix
    ../../../home/cli/git.nix
    ../../../home/gui/kitty.nix
    ../../../home/tui/nixCats.nix
  ];

  home = {
    username = user.username;
    homeDirectory = "/home/${user.username}";

    packages = with pkgs; [
      delta
      git
      git-credential-oauth
      kitty
    ];

    stateVersion = "25.11";
  };

  programs.home-manager.enable = true;
}
