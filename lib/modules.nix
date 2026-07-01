{
  inputs,
  lib,
  ...
}:
{
  flake.lib.loadNixOSAndHMModules =
    config: modules: user:
    assert builtins.isAttrs config;
    assert builtins.isList modules;
    let
      checks = map (
        module:
        lib.throwIf (
          !(builtins.hasAttr module config.flake.modules.nixos)
          && !(builtins.hasAttr module config.flake.modules.homeManager)
        ) "loadNixOSAndHMModules: module '${module}' has neither a NixOS nor a Home Manager module." true
      ) modules;
    in
    builtins.deepSeq checks (
      (map (module: config.flake.modules.nixos.${module} or { }) modules)
      ++ [
        {
          imports = [ inputs.home-manager.nixosModules.home-manager ];

          home-manager.users.${user}.imports = map (
            module: config.flake.modules.homeManager.${module} or { }
          ) modules;
        }
      ]
    );
}
