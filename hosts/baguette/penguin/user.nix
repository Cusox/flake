{ pkgs, user, ... }:

let
  username = user.username;

  sshKeys = import ../../../config/keys.nix;
in
{
  users.users = {
    ${username} = {
      isNormalUser = true;
      uid = 1000;
      linger = true;
      extraGroups = [ "wheel" ];
      shell = pkgs.zsh;

      openssh.authorizedKeys.keys = builtins.attrValues sshKeys;
    };
  };

  security.sudo.wheelNeedsPassword = false;
}
