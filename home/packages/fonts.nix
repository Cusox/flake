{ pkgs, ... }:

{
  fonts.fontconfig.enable = true;

  home.packages = [
    pkgs.maple-mono.NF-CN-unhinted
  ];
}
