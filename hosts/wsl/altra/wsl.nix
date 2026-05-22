{ pkgs, user, ... }:

let
  username = user.username;
in
{
  wsl = {
    enable = true;
    defaultUser = username;

    wslConf = {
      boot.systemd = true;
      network.generateResolvConf = false;
    };

    useWindowsDriver = true;
  };

  environment = {
    sessionVariables = {
      LD_LIBRARY_PATH = [
        "/run/opengl-driver/lib"
        "${pkgs.openssl.out}/lib"
      ];

      LIBGL_DRIVERS_PATH = "${pkgs.mesa}/lib/dri";
      GBM_BACKENDS_PATH = "${pkgs.mesa}/lib/gbm";

      GALLIUM_DRIVER = "d3d12";
      MESA_LOADER_DRIVER_OVERRIDE = "d3d12";
      MESA_D3D12_DEFAULT_ADAPTER_NAME = "NVIDIA";
    };
  };
}
