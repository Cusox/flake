{ pkgs, user, ... }:

let
  username = user.username;
in
{
  users.users = {
    ${username} = {
      isNormalUser = true;
      uid = 1000;
      linger = true;
      extraGroups = [ "wheel" ];
      shell = pkgs.zsh;
    };
  };

  security.sudo.wheelNeedsPassword = false;
}
