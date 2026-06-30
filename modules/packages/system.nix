{
  flake.modules.packages = {
    nixos.system =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [
          # download
          curl
          wget

          # archive
          zip
          unzip
        ];
      };
  };
}
