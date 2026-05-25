{ devices }:

{ config, ... }:

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
    systemd.enable = true;

    availableKernelModules = [
      "virtio_net"
      "virtio_pci"
      "virtio_mmio"
      "virtio_blk"
      "virtio_scsi"
    ];

    kernelModules = [
      "virtio_balloon"
      "virtio_console"
      "virtio_rng"
    ];
  };

  boot.loader.grub = {
    inherit devices;

    enable = !config.boot.isContainer;
    default = "saved";
  };
}
