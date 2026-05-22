{ hostName, ... }:

{
  imports = [
    ./garcon.nix
    ./user.nix
  ];

  networking.hostName = hostName;

  services.dbus.enable = true;

  system.stateVersion = "25.11";
}
