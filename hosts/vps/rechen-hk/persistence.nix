{ inputs, user, ... }:

let
  username = user.username;
in
{
  imports = [
    inputs.impermance.nixosModules.impermanence
  ];

  environment.persistence."/nix/persist" = {
    enable = true;
    hideMounts = true;
    directories = [
      "/var"
      "/etc/NetworkManager/system-connections"
      "/etc/ssh"
      "/home"
      "/root"
    ];
    files = [
      "/etc/machine-id"
    ];
    users.${username} = {
      directories = [
        ".config"
      ];
      files = [ ];
    };
  };
}
