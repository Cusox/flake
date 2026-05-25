{ hostName, ... }:

{
  imports = [
    ../_bootstrap/filesystem.nix
    ../_bootstrap/network.nix
    ../_bootstrap/openssh.nix
    ../_bootstrap/user.nix

    (import ../../../modules/system/boot.nix { devices = [ "/dev/vda" ]; })
  ];

  time.timeZone = "Asia/Shanghai";

  networking.hostName = hostName;

  services.dbus.enable = true;

  system.stateVersion = "25.11";
}
