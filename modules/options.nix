{ lib, ... }:
{
  options.flake.modules = {
    nixos = lib.mkOption {
      type = lib.types.attrsOf lib.types.raw;
      default = { };
    };

    homeManager = lib.mkOption {
      type = lib.types.attrsOf lib.types.raw;
      default = { };
    };

    packages = {
      nixos = lib.mkOption {
        type = lib.types.attrsOf lib.types.raw;
        default = { };
      };
      homeManager = lib.mkOption {
        type = lib.types.attrsOf lib.types.raw;
        default = { };
      };
    };
  };
}
