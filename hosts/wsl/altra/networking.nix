{ hostName, ... }:

{
  networking = {
    hostName = hostName;

    resolvconf.enable = true;

    nameservers = [
      "192.168.31.3"
    ];
  };
}
