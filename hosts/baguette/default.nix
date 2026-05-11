{ inputs, hosts, ... }:
let
  nixpkgs = inputs.nixpkgs;
  lib = nixpkgs.lib;
  nixos-crostini = inputs.nixos-crostini;

  baguetteHosts = lib.filterAttrs(name: host: host.dir == "baguette") hosts;

  mkBaguetteHost = name: host:
  let
    system = host.arch;

    specialArgs = {
      inherit inputs;
      hostName = name;
      user = host.user;
    };
  in
  lib.nixosSystem {
    inherit system specialArgs;

    modules = [ 
      {
        nixpkgs.config.allowUnfree = true;
      }
      ./${name} 
      nixos-crostini.nixosModules.baguette
    ];
  };
in
lib.mapAttrs mkBaguetteHost baguetteHosts
