let
  users = import ./users.nix;

  x86l = "x86_64-linux";
  arml = "aarch64-linux";
in
{
  byra = {
    dir = "baguette";
    arch = x86l;
    user = users.default;
  };
}
