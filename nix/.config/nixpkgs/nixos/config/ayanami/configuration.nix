# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

let
  secrets = import ./secrets.nix;
in

{
  imports = [
    ./hardware-configuration.nix
    ../../common/gnome.nix
    ../../common/fonts.nix
  ] ++ (import ./../../modules/module-list.nix);

  boot = {
    loader = {
      grub = {
        enable = true;
        efiSupport = false;
	      device = "/dev/sda";
        extraEntries = ''
	        menuentry "Windows" {
	          chainloader (hd0,1)+1
	        }
	      '';
      };
    };
    initrd.luks.devices = [{
      name = "root";
      device = "/dev/disk/by-uuid/079a4194-9077-4ac4-9dcf-f501fe77e9cd";
      allowDiscards = true;
    }];
    kernelParams = [ "ipv6.disable=1" ];
    kernelModules = [ "snd-seq" "snd-rawmidi" ];
    cleanTmpDir = true;
    supportedFilesystems = [ "zfs" "nfs" ];
  };

  fileSystems."/".options = [ "noatime" "nodiratime" "discard" ];

  networking = {
    hostId = "def9e89c";
    hostName = "ayanami.maher.fyi";
    enableIPv6 = false;
    firewall = {
      enable = true;
      trustedInterfaces = [ "lo" ];
      allowedTCPPorts = [
        22000 # syncthing
      ];
      allowedUDPPorts = [
        21027 # syncthing
      ];
    };
    extraHosts = ''
      114.111.153.165 drac.tomoyo.maher.fyi
      192.168.1.215   hoshijiro.maher.fyi
      192.168.1.245   aisaka.maher.fyi
      127.0.0.1       ayanami.maher.fyi
    '';
  };

  i18n = {
    consoleFont = "Lat2-Terminus16";
    defaultLocale = "en_US.UTF-8";
    consoleUseXkbConfig = true;
    supportedLocales = [ "en_US.UTF-8/UTF-8" ];
  };

  time.timeZone = "Asia/Tokyo";

  services.openntpd = {
    enable = true;
    servers = [
      "0.jp.pool.ntp.org"
	    "1.jp.pool.ntp.org"
	    "2.jp.pool.ntp.org"
	    "3.jp.pool.ntp.org"
    ];
  };

  environment.systemPackages = with pkgs; [
    local-packages.nextcloud-client
    psmisc
  ];

  services.udev.packages = [ pkgs.android-udev-rules ];

  services.pcscd.enable = true;

  services.local.pia-nm = {
    enable = true;
    inherit (secrets.services.local.pia-nm) username password;
  };

  nixpkgs = {
    config.allowUnfree = true;
    overlays = [
      (import ../../../packages/overlay.nix)
    ];
  };

  nix = {
    trustedUsers = [ "root" ];
    nixPath = [
      "nixpkgs=${pkgs.callPackage ./lib/nixpkgs.nix {}}"
      "nixos-config=/etc/nixos/configuration.nix"
    ];
    distributedBuilds = false;
    trustedBinaryCaches = [ "http://nixos-arm.dezgeg.me/channel" ];
  };

  virtualisation.docker.enable = true;

  security.sudo.wheelNeedsPassword = false;

  environment.shells = [ pkgs.bashInteractive pkgs.zsh ];

  programs.zsh.enable = true;

  users.mutableUsers = true;
  
  users.users.eqyiel = {
    isNormalUser = true;
    uid = 1000;
    initialPassword = "hunter2";
    shell = pkgs.zsh;
    extraGroups = [
     "audio"
     "docker"
     "networkmanager"
     "systemd-journal"
     "wheel"
    ];
  };

  documentation.nixos.enable = false;

  system.stateVersion = "19.03pre";
}
