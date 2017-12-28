# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

let
  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/installer/tools/tools.nix#L10
  makeProg = args: pkgs.substituteAll (args // {
    dir = "bin";
    isExecutable = true;
  });

in

{
  imports = [
    ./hardware-configuration.nix
    ./../../../packages/overrides.nix
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
    networkmanager = {
      enable = true;
      packages = [
        pkgs.gnome3.networkmanager_openvpn
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
    # nextcloud-client
    local-packages.javaws-desktop-file
    local-packages.nautilus-python # nextcloud packages nautilus extensions
    mpdris2 # notifications in Gnome for MPD
  ] ++
  (import ./../../../common/package-lists/essentials.nix) {
    inherit pkgs;
  } ++
  (import ./../../../common/package-lists/x11-tools.nix) {
    inherit pkgs;
  } ++
  (import ./../../../common/package-lists/audio-tools.nix) {
    inherit pkgs;
  };

  environment.pathsToLink = [
    "/share/emacs"   # Necessary for emacs support files (mu4e)
  ];

  environment.etc."xdg/gtk-3.0/settings.ini" = {
    text = ''
      [Settings]
      gtk-key-theme-name = Emacs
    '';
  };

  environment.gnome3.excludePackages = [
    # gnome-software is fixed in
    # https://github.com/NixOS/nixpkgs/commit/6a17c5a46c933deb6c856be8602ea9f5d6560e98
    # but probably doesn't do anything useful with nixos anyway, at least before
    # something like this is done:
    # RFC: Generating AppStream Metadata #15932:
    # https://github.com/NixOS/nixpkgs/issues/15932
    pkgs.gnome3.gnome-software
    pkgs.gnome3.evolution
    pkgs.gnome3.epiphany
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

  fonts.fonts = (import ./../../../common/package-lists/fonts.nix) {
    inherit pkgs;
  };

  services.xserver = {
    enable = true;
    layout = "us";
    libinput = {
      enable = true;
      tapping = true;
    };
    xkbOptions = "caps:hyper";
    exportConfiguration = true; # for xkbcomp
    # doesn't work
    # inputClassSections = [
    #   ''
    #     Identifier     "Enable libinput for TrackPoint"
    #     MatchIsPointer "on"
    #     Driver         "libinput"
    #     Option         "ScrollMethod" "button"
    #     Option         "ScrollButton" "8"
    #   ''
    # ];
    displayManager.gdm = {
      enable = true;
      autoLogin = {
        enable = true;
        user = "eqyiel";
      };
    };
    desktopManager.gnome3 = {
      enable = true;
      # TODO: check out this https://github.com/NixOS/nixpkgs/pull/29392#issuecomment-343368926
      # extraGSettingsOverrides = ''
      #   [org.gnome.desktop.input-sources]
      #   sources=[('xkb', 'cz+qwerty')]
      #   xkb-options=['compose:caps']

      #   [org.gnome.desktop.background]
      #   primary-color='#000000'
      #   secondary-color='#000000'
      #   picture-uri='${backgrounds.reflection_by_yuumei}'

      #   [org.gnome.desktop.screensaver]
      #   lock-delay=3600
      #   lock-enabled=true
      #   picture-uri='${backgrounds.undersea_city_by_mrainbowwj}'
      #   primary-color='#000000'
      #   secondary-color='#000000'
      # '';

      extraGSettingsOverrides = ''
        [org/gnome/desktop/input-sources]
        show-all-sources=true
        sources=[('xkb', 'us')]
        xkb-options=['caps:hyper']

        [org/gnome/desktop/interface]
        gtk-key-theme='Emacs'

        [org/gnome/gnome-screenshot]
        last-save-directory='file:///home/eqyiel'
      '';
    };
  };

  services.postgresql.enable = true;

  services.local--pia-nm.enable = true;

  virtualisation.virtualbox.host.enable = true;

  hardware.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
  };

  # Needed for Steam
  # https://github.com/NixOS/nixpkgs/issues/19518#issuecomment-253626165
  hardware.opengl = {
    driSupport = true;
    driSupport32Bit = true;
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
