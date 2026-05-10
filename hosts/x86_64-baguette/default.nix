{ inputs, lib, user, ... }:
let
  nixos-crostini = inputs.nixos-crostini;

  targetSystem = "x86_64-linux";

  specialArgs = { inherit inputs user; };

  buildHost = name: lib.nixosSystem {
    system = targetSystem;
    inherit specialArgs;
    modules = [ 
      ./${name} 
      nixos-crostini.nixosModules.baguette
    ];
  };
in
{
  byra = buildHost "byra";
}
