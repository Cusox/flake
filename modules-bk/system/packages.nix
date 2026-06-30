{ pkgs, ... }:

{
  programs.zsh.enable = true;

  environment = {
    systemPackages = with pkgs; [
      git
      curl
      wget
      kitty.terminfo
    ];

    pathsToLink = [
      "/share/zsh"
    ];
  };
}
