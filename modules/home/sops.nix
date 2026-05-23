{ config, inputs, ... }:

let
  sops-nix = inputs.sops-nix;
in
{
  imports = [
    sops-nix.homeManagerModules.sops
  ];

  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

    defaultSopsFile = ../../secrets/home.yaml;
  };
}
