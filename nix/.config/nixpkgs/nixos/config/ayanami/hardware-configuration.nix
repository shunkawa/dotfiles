{ config, lib, pkgs, ... }:

{
  imports = [<nixpkgs/nixos/modules/installer/scan/not-detected.nix>];

  boot = {
    initrd.availableKernelModules = [
      "xhci_pci"
      "ehci_pci"
      "ahci"
      "usb_storage"
      "sd_mod"
      "rtsx_pci_sdmmc"
    ];
    kernelModules = ["kvm-intel"];
    extraModulePackages = [];
  };


  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/a33b25a5-1501-413f-9c41-92062a8609fd";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/5ad5552f-3d6a-4b3e-ab46-b8c2324f3d92";
      fsType = "ext4";
    };
  }

  swapDevices = [];
  nix.maxJobs = lib.mkDefault 4;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
