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
    ../../common/steam.nix
    ../../common/virtualisation.nix
  ] ++ (import ./../../modules/module-list.nix);

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    initrd.luks.devices = [{
      name = "root";
      device = "/dev/sda2";
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

  time.timeZone = "Australia/Adelaide";

  services.openntpd = {
    enable = true;
    servers = [
      "0.au.pool.ntp.org"
	    "1.au.pool.ntp.org"
	    "2.au.pool.ntp.org"
	    "3.au.pool.ntp.org"
    ];
  };

  environment.systemPackages = with pkgs; [
    local-packages.nextcloud-client
    psmisc
  ];

  krb5 = {
    enable = true;
    libdefaults = {
      default_realm = "HOSHIJIRO.MAHER.FYI";
    };

    realms = {
      "HOSHIJIRO.MAHER.FYI" = {
        admin_server = "hoshijiro.maher.fyi";
        kdc = "hoshijiro.maher.fyi";
        default_principal_flags = "+preauth";
      };
    };

    domain_realm = ''
      hoshijiro.maher.fyi = HOSHIJIRO.MAHER.FYI;
      .hoshijiro.maher.fyi = HOSHIJIRO.MAHER.FYI;
    '';

    extraConfig = ''
      [logging]
        kdc          = SYSLOG:NOTICE
        admin_server = SYSLOG:NOTICE
        default      = SYSLOG:NOTICE
    '';
  };

  services.udev.packages = [ pkgs.android-udev-rules ];

  services.pcscd.enable = true;

  services.postgresql.enable = true;

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
    # Use this if you want to force remote building
    # maxJobs = 0;
    trustedUsers = [ "root" ];
    nixPath = [
      # symlink from ~/git/personal/dotfiles/nix/.config/nixpkgs/nixos/config/ayanami/lib/nixpkgs
      "nixpkgs=/etc/nixos/lib/nixpkgs"
      # symlink from ~/git/personal/dotfiles/nix/.config/nixpkgs/nixos/config/ayanami/configuration.nix
      "nixos-config=/etc/nixos/configuration.nix"
    ];
    distributedBuilds = false;
    trustedBinaryCaches = [ "http://nixos-arm.dezgeg.me/channel" ];
    buildMachines = [
      {
        hostName = "tomoyo.maher.fyi";
        sshUser = "nix-builder";
        sshKey = "/root/.ssh/id_nix-builder";
        system = "x86_64-linux";
        maxJobs = 4;
      }
    ];
  };

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
     "networkmanager"
     "systemd-journal"
     "wheel"
    ];
  };

  system.stateVersion = "18.03";
}
