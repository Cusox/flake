{ pkgs, ... }:
{
  programs.starship = {
    enable = true;

    extraPackages = [
      pkgs.jj-starship
    ];

    settings = {
      custom.jj = {
        when = "jj-starship detect";
        shell = [ "jj-starship" ];
        format = "$output ";
      };
    };

    presets = [
      "nerd-font-symbols"
    ];

    enableZshIntegration = true;
  };
}
