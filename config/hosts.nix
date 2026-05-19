let
  users = import ./users.nix;

  x86l = "x86_64-linux";
  arml = "aarch64-linux";
in
{
  penguin = {
    type = "baguette";
    arch = x86l;
    user = users.baguette;
  };
  altra = {
    type = "wsl";
    arch = x86l;
    user = users.default;
  };
  omit = {
    type = "wsl";
    arch = x86l;
    user = users.default;
  };
  gpu = {
    type = "home";
    arch = x86l;
    user = users.gpu;
  };
}
