{ inputs, user, ... }:

let
  sops-nix = inputs.sops-nix;
in
{
  imports = [
    sops-nix.nixosModules.sops
  ];

  sops = {
    age.keyFile = "/home/${user.username}/.config/sops/age/keys.txt";

    defaultSopsFile = ../../../secrets/default.yaml;

    secrets.github_token = { };
  };
}
