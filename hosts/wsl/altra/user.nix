{ pkgs, user, ... }:

{
  programs.zsh.enable = true;

  users.users = {
    ${user.username} = {
      linger = true;
      shell = pkgs.zsh;
    };
  };

  security.sudo.wheelNeedsPassword = false;
}
