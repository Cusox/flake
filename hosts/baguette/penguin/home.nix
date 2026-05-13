{ inputs, user, pkgs, ...}:
{
  imports = [
    ../../../home/fonts.nix
    ../../../home/cli/git-credential-oauth.nix
    ../../../home/gui/kitty.nix
    ../../../home/tui/nixCats.nix
  ];

  home = {
    username = user.username;
    homeDirectory = "/home/${user.username}";

    packages = with pkgs; [
      git-credential-oauth
      kitty
    ];

    stateVersion = "25.11";
  };

  programs.home-manager.enable = true;
}
