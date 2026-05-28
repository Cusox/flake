{ inputs, ... }:

{
  imports = [
    inputs.impermance.nixosModules.impermanence
  ];

  environment.persistence."/nix/persist" = {
    enable = true;
    hideMounts = true;
    directories = [
      "/var"
      "/etc/ssh"
      "/root"
    ];
    files = [
      "/etc/machine-id"
    ];
  };
}
