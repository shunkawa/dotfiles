{ config, lib, pkgs, ... }:

{
  imports = [
    <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
  ];

  boot = {
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [];
    initrd.availableKernelModules = [
      "ehci_pci"
      "ahci"
      "usb_storage"
      "sd_mod"
      "rtsx_pci_sdmmc"
    ];
  };

  fileSystems = {
    "/" = {
      device = "/dev/mapper/vg-root";
      fsType = "ext4";
    };
    "/boot" = {
       device = "/dev/disk/by-uuid/33C7-BD51";
       fsType = "vfat";
    };
  };

  swapDevices = [{ device = "/dev/mapper/vg-swap"; }];

  nix.maxJobs = lib.mkDefault 4;
}
