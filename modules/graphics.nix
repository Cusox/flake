{
  flake.modules.nixos.graphics = { pkgs, ... }: {
    hardware.graphics = {
      enable = true;

      extraPackages = with pkgs; [
        libva
        libva-vdpau-driver
        libvdpau-va-gl
      ];

      extraPackages32 = with pkgs; [
        libva
        libva-vdpau-driver
        libvdpau-va-gl
      ];
    };
  };
}
