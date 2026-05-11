{
  description = "Cusox's NixOS Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixos-crostini = {
      url = "github:aldur/nixos-crostini";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: 
  let
    hosts = import ./config/hosts.nix;

    args = {
      inherit inputs hosts;
    };
  in
  {
    nixosConfigurations = import ./hosts args;
  };
}
