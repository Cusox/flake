{ pkgs, user, ... }:

{
  users.users = {
    ${user.username} = {
      isNormalUser = true;
      uid = 1000;
      linger = true;
      extraGroups = [ "wheel" ];
      shell = pkgs.zsh;
    };
  };

  security.sudo.wheelNeedsPassword = false;
}
