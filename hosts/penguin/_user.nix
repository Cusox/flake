{ pkgs, ... }:
{
  users = {
    mutableUsers = false;
    users = {
      chronos = {
        isNormalUser = true;
        shell = pkgs.zsh;
        extraGroups = [ "wheel" ];
      };
    };
    allowNoPasswordLogin = true;
  };
  security.sudo.wheelNeedsPassword = false;
}
