{
  inputs,
  user,
  hostName,
  homeModule,
  ...
}:

let
  home-manager = inputs.home-manager;

  username = user.username;

  specialArgs = {
    inherit inputs user hostName;
  };
in
{
  imports = [ home-manager.nixosModules.home-manager ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = specialArgs;

    users.${username} = homeModule;
  };
}
