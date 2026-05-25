{ inputs, ... }:

{
  imports = [ inputs.disko.nixosModules.disko ];

  disko = {
    enableConfig = false;

    devices = {
      disk.main = {
        imageSize = "2G";
        device = "/dev/vda";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "1M";
              type = "EF02";
              priority = 0;
            };

            ESP = {
              name = "ESP";
              size = "512M";
              type = "EF00";
              priority = 1;
              content = {
                type = "filesystem";
                format = "vfat";
                extraArgs = [
                  "-n"
                  "BOOT"
                ];
                mountpoint = "/boot";
                mountOptions = [
                  "fmask=0077"
                  "dmask=0077"
                ];
              };
            };

            nix = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "btrfs";
                extraArgs = [
                  "-L"
                  "NIX"
                ];
                mountpoint = "/nix";
                mountOptions = [
                  "compress-force=zstd"
                  "nosuid"
                  "nodev"
                ];
              };
            };
          };
        };
      };
      nodev."/" = {
        fsType = "tmpfs";
        mountOptions = [
          "relatime"
          "mode=755"
          "nosuid"
          "nodev"
        ];
      };
    };
  };
}
