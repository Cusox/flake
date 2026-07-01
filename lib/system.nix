{
  inputs,
  config,
  lib,
  ...
}:
let
  mkNixOS =
    system: cls: host: user:
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        config.flake.hosts.${host}
        config.flake.modules.${cls}
        config.flake.modules.nixos.homeManager
        {
          home-manager.users.${user}.imports = [
            (config.flake.modules.homeManager.homeManager user)
          ];

          networking.hostName = lib.mkForce host;

          nixpkgs = {
            hostPlatform = lib.mkDefault system;
            config.allowUnfree = true;
          };

          system.stateVersion = "26.05";
        }
      ];
    };
in
{
  flake.lib.mkSystem = {
    baguette = mkNixOS "x86_64-linux" "baguette";
    wsl = mkNixOS "x86_64-linux" "wsl";
    linux = mkNixOS "x86_64-linux" "nixos";
  };
}
