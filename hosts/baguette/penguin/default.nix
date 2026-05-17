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

  hardware.graphics.enable = true;

  networking.hostName = hostName;

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
    };
  };

  services.dbus.enable = true;

  programs.zsh.enable = true;

  users.users = {
    ${user.username} = {
      isNormalUser = true;
      uid = 1000;
      linger = true;
      extraGroups = [ "wheel" ];
      shell = pkgs.zsh;
    };
  };

  security.sudo.wheelNeedsPassword = false;

  system.stateVersion = "25.11";
}
