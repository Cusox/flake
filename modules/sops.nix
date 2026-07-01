{
  inputs,
  lib,
  ...
}:
let
  sopsDefault = {
    defaultSopsFile = ../secrets/global.yaml;
    age.generateKey = true;
  };
in
{
  flake.modules = {
    nixos.sops = {
      imports = [
        inputs.sops-nix.nixosModules.sops
      ];

      sops = lib.recursiveUpdate sopsDefault {
        age.keyFile = "/etc/sops/age/keys.txt";
      };
    };
    homeManager.sops = { config, ... }: {
      imports = [
        inputs.sops-nix.homeManagerModules.sops
      ];

      sops = lib.recursiveUpdate sopsDefault {
        age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
      };
    };
  };
}
