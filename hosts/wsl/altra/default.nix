{
  pkgs,
  hostName,
  user,
  ...
}:
{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  wsl = {
    enable = true;
    defaultUser = user.username;

    wslConf = {
      boot.systemd = true;
      network.generateResolvConf = false;
    };

    useWindowsDriver = true;
  };

  hardware.graphics.enable = true;

  networking = {
    hostName = hostName;

    resolvconf.enable = true;

    nameservers = [
      "192.168.31.3"
    ];
  };

  environment = {
    pathsToLink = [ "/share/zsh" ];

    systemPackages = with pkgs; [
      git
      curl
      wget
    ];

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

  services.dbus.enable = true;

  programs.zsh.enable = true;

  users.users = {
    ${user.username} = {
      linger = true;
      shell = pkgs.zsh;
    };
  };

  security.sudo.wheelNeedsPassword = false;

  system.stateVersion = "25.11";
}
