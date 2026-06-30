{ lib, ... }:
{
  options.flake.hosts = lib.mkOption {
    type = lib.types.attrsOf lib.types.raw;
    default = { };
  };
}
