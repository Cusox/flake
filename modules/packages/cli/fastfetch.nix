{ lib, ... }:
{
  flake.modules.packages = {
    homeManager.fastfetch = {
      programs.fastfetch.enable = true;

      programs.zsh.initContent = lib.mkOrder 2000 ''
        fastfetch
      '';
    };
  };
}
