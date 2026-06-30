{ inputs, ... }:

let
  sops-nix = inputs.sops-nix;
in
{
  imports = [
    sops-nix.nixosModules.sops
  ];

  sops = {
    age.keyFile = "/var/lib/sops-nix/keys.txt";

    defaultSopsFile = ../../secrets/system.yaml;
  };
}
