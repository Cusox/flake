{ pkgs, user, ... }:

let
  username = user.username;
  keys = import ../../../config/ssh/keys.nix;
in
{
  users = {
    mutableUsers = false;

    users.${username} = {
      shell = pkgs.zsh;

      hashedPassword = "$y$j9T$nA42aXHBmWetGwUfUeGPU/$kg/e8qqS/F0Pxo.jvbmWJzLB4xyOoKF/B8P9Fkfo516";

      openssh.authorizedKeys.keys = builtins.attrValues keys;
    };
  };
}
