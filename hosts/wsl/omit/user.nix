{ pkgs, user, ... }:

let
  username = user.username;
in
{
  programs.zsh.enable = true;

  users.users = {
    ${username} = {
      linger = true;
      shell = pkgs.zsh;
    };
  };

  security.sudo.wheelNeedsPassword = false;
}
