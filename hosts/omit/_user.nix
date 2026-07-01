{ pkgs, ... }:
{
  users = {
    mutableUsers = false;
    users = {
      cusox = {
        isNormalUser = true;
        shell = pkgs.zsh;
        extraGroups = [ "wheel" ];
      };
    };
    allowNoPasswordLogin = true;
  };
  security.sudo.wheelNeedsPassword = false;
}
