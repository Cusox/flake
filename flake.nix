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

  outputs = { self, nixpkgs, ... }@inputs: 
  let
    lib = nixpkgs.lib;

    user = {
      username = "Cusox";
      useremail = "cusoxlee@gmail.com";
    };

    args = {
      inherit
        inputs
	lib
	user
	;
    };
  in
  {
    nixosConfigurations = import ./hosts args;
  };
}
