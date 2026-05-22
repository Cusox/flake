{ pkgs, ... }:

{
  programs.zsh.enable = true;

  environment = {
    systemPackages = with pkgs; [
      git
      curl
      wget
    ];

    pathsToLink = [
      "/share/zsh"
    ];
  };
}
