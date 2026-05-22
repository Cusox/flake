{ inputs, user, ... }:

let
  sops-nix = inputs.sops-nix;

  username = user.username;
in
{
  imports = [
    sops-nix.nixosModules.sops
  ];

  sops = {
    age.keyFile = "/home/${username}/.config/sops/age/keys.txt";

    defaultSopsFile = ../../secrets/default.yaml;
  };
}
