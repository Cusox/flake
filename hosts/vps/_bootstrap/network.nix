{ hostConfig, ... }:

let
  ip = hostConfig.ip;
in
{
  networking.useDHCP = false;

  services.resolved.enable = true;

  systemd.network = {
    enable = true;
    networks."10-eth0" = {
      matchConfig.Name = "eth0";
      address = [ ip.address ];
      gateway = [ ip.gateway ];
      dns = [
        "1.1.1.1"
        "8.8.8.8"
      ]
      ++ ip.dns;
    };
  };
}
