{ devices }:

{ config, pkgs, ... }:

{
  boot.kernelParams = [
    "audit=0"
    "net.ifnames=0"
  ];

  boot.initrd = {
    compressor = "zstd";
    compressorArgs = [
      "-19"
      "-T0"
    ];

    availableKernelModules = [
      "virtio_net"
      "virtio_pci"
      "virtio_mmio"
      "virtio_blk"
      "virtio_scsi"
      "btrfs"
    ];

    kernelModules = [
      "virtio_balloon"
      "virtio_console"
      "virtio_rng"
    ];

    systemd = {
      enable = true;
      storePaths = [ pkgs.btrfs-progs ];
      services.rollback-root = {
        description = "Rollback Btrfs root subvolume";
        wantedBy = [
          "initrd.target"
        ];
        after = [
          "dev-disk-by\\x2dlabel-NIX.device"
        ];
        requires = [
          "dev-disk-by\\x2dlabel-NIX.device"
        ];
        before = [
          "sysroot.mount"
        ];
        unitConfig.DefaultDependencies = "no";
        serviceConfig = {
          Type = "oneshot";
        };
        script = ''
          mkdir -p /btrfs_tmp

          mount -o subvol=/ /dev/disk/by-label/NIX /btrfs_tmp

          if [ -e /btrfs_tmp/root ]; then
            mkdir -p /btrfs_tmp/old_roots
            timestamp=$(date -u -d "@$(stat -c %Y /btrfs_tmp/root)" "+%Y-%m-%d_%H:%M:%S")
            mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$timestamp"
          fi

          delete_subvolume_recursively() {
            IFS=$'\n'
            for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
              delete_subvolume_recursively "/btrfs_tmp/$i"
            done
            btrfs subvolume delete "$1"
          }

          if [ -d /btrfs_tmp/old_roots ]; then
            for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +30); do
              delete_subvolume_recursively "$i"
            done
          fi

          btrfs subvolume create /btrfs_tmp/root

          umount /btrfs_tmp
        '';
      };
    };

  };

  boot.loader.grub = {
    inherit devices;

    enable = !config.boot.isContainer;
    default = "saved";
  };
}
