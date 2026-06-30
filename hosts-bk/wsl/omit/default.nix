{ hostName, ... }:

{
  imports = [
    ./user.nix
    ./wsl.nix
  ];

  networking.hostName = hostName;

  services.dbus.enable = true;

  system.stateVersion = "25.11";
}
