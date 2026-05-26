{
  fileSystems."/" = {
    device = "/dev/disk/by-label/NIX";
    fsType = "btrfs";
    options = [
      "subvol=/root"
      "compress-force=zstd"
    ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/BOOT";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-label/NIX";
    fsType = "btrfs";
    options = [
      "subvol=/nix"
      "compress-force=zstd"
      "nosuid"
      "nodev"
    ];
  };

  fileSystems."/nix/persist" = {
    device = "/dev/disk/by-label/NIX";
    fsType = "btrfs";
    neededForBoot = true;
    options = [
      "subvol=/persist"
      "compress-force=zstd"
      "nosuid"
      "nodev"
    ];
  };
}
