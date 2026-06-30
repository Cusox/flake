{
  imports = [
    ./networking.nix
    ./user.nix
    ./wsl.nix
  ];

  services.dbus.enable = true;

  system.stateVersion = "25.11";
}
