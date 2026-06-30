{
  inputs,
  lib,
  ...
}:
{
  flake.lib.loadNixOSAndHMPackages =
    config: packages: user:
    assert builtins.isAttrs config;
    assert builtins.isList packages;
    let
      checks = map (
        package:
        lib.throwIf
          (
            !(builtins.hasAttr package config.flake.modules.packages.nixos)
            && !(builtins.hasAttr package config.flake.modules.packages.homeManager)
          )
          "loadNixOSAndHMPackages: package '${package}' has neither a NixOS nor a Home Manager package."
          true
      ) packages;
    in
    builtins.deepSeq checks (
      (map (package: config.flake.modules.packages.nixos.${package} or { }) packages)
      ++ [
        {
          imports = [ inputs.home-manager.nixosModules.home-manager ];

          home-manager.users.${user}.imports = map (
            package: config.flake.modules.packages.homeManager.${package} or { }
          ) packages;
        }
      ]
    );
}
