{ hostName, ... }:

{
  imports = [
    ../_bootstrap/network.nix
    ../_bootstrap/openssh.nix
    ../_bootstrap/user.nix
  ];

  time.timeZone = "Asia/Shanghai";

  networking.hostName = hostName;

  services.dbus.enable = true;

  system.stateVersion = "25.11";
}
