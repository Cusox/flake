{ inputs, hosts, ... }:
let
  nixpkgs = inputs.nixpkgs;
  nixos-crostini = inputs.nixos-crostini;
  home-manager = inputs.home-manager;
  lib = nixpkgs.lib;

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
      { nixpkgs.config.allowUnfree = true; }
      ./${name} 
      ./${name}/garcon.nix
      nixos-crostini.nixosModules.baguette
      home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = specialArgs;
        home-manager.users.${host.user.username} = ./${name}/home.nix;
      }
    ];
  };
in
lib.mapAttrs mkBaguetteHost baguetteHosts
