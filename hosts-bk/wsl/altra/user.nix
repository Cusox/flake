{ pkgs, user, ... }:

let
  username = user.username;
in
{
  users.users = {
    ${username} = {
      linger = true;
      shell = pkgs.zsh;
    };
  };

  security.sudo.wheelNeedsPassword = false;
}
