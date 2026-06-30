{ hostName, ... }:

{
  imports = [
    ./disko.nix
    ./filesystem.nix
    ./firewall.nix
    ./network.nix
    ./openssh.nix
    ./user.nix
  ];

  time.timeZone = "Asia/Shanghai";

  networking.hostName = hostName;

  services.dbus.enable = true;

  system.stateVersion = "25.11";

}
