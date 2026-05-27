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
      "/home"
      "/root"
    ];
    files = [
      "/etc/machine-id"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
    ];
    users.${username} = {
      directories = [
        ".config"
      ];
      files = [ ];
    };
  };
}
