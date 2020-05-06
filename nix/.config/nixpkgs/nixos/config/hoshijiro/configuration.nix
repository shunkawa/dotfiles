{ config, lib, pkgs, ... }:

let

  sshKeys = import ./../../../common/ssh-keys.nix;

  secrets = import ./secrets.nix;

in rec {
  imports = [
    ./config
    ../../common/gnome.nix
    ../../common/steam.nix
    ../../common/fonts.nix
  ] ++ (import ./../../modules/module-list.nix);

  fileSystems = {
    "/" = {
      device = "rpool/ephemeral/root";
      fsType = "zfs";
      neededForBoot = true;
    };

    "/boot" = {
      device = "/dev/disk/by-partuuid/25ec9e72-4e5a-42f2-89e5-d52760bde1f1";
      fsType = "vfat";
      neededForBoot = true;
    };

    "/nix" = {
      device = "rpool/ephemeral/nix";
      fsType = "zfs";
      neededForBoot = true;
    };

    "/mnt/persistent/etc" = {
      device = "tank/persistent/etc";
      fsType = "zfs";
      neededForBoot = true;
    };

    "/mnt/persistent/var" = {
      device = "tank/persistent/var";
      fsType = "zfs";
      neededForBoot = true;
    };

    "/mnt/persistent/home" = {
      device = "tank/persistent/home";
      fsType = "zfs";
      neededForBoot = true;
    };

    "/home" = {
      device = "/mnt/persistent/home";
      options = [ "bind" ];
    };

    "/var/lib/nextcloud" = {
      device = "/mnt/persistent/var/lib/nextcloud";
      options = [ "bind" ];
    };

    "/var/lib/nextcloud/store-apps" = {
      device = "tank/ephemeral/var/lib/nextcloud/store-apps";
      fsType = "zfs";
    };

    "/var/lib/nextcloud/data/appdata_ockwss45h91a" = {
      device = "tank/ephemeral/var/lib/nextcloud/data/appdata_ockwss45h91a";
      fsType = "zfs";
    };

    "/export/home" = {
      device = "/home";
      options = [ "bind" ];
    };

    "/export/transmission" = {
      device = "/mnt/persistent/var/lib/transmission";
      options = [ "bind" ];
    };
  };

  swapDevices = [{ device = "/dev/disk/by-uuid/d810ed98-18b6-46f5-8724-366e5bde060b"; }];

  systemd = {
    tmpfiles = {
      rules = [
        "L /var/lib/acme - - - - /mnt/persistent/var/lib/acme"
        "L /var/lib/bluetooth - - - - /mnt/persistent/var/lib/bluetooth"
        "L /var/lib/postgresql - - - - /mnt/persistent/var/lib/postgresql"
        "L /var/lib/transmission - - - - /mnt/persistent/var/lib/transmission"
      ];
    };
  };

  powerManagement.cpuFreqGovernor = "powersave";

  boot = {
    zfs = {
      forceImportAll = false;
      forceImportRoot = false;
      requestEncryptionCredentials = true;
    };
    loader = {
      systemd-boot = {
        enable = true;
      };
      efi = {
        canTouchEfiVariables = true;
      };
    };
    cleanTmpDir = true;
    extraModulePackages = [];
    kernelModules = [ "kvm-intel" ];
    supportedFilesystems = [ "zfs" "nfs" "ntfs" ];
    # https://discourse.nixos.org/t/disk-encryption-on-nixos-servers-how-when-to-unlock/5030/11
    kernelParams = ["ip=192.168.1.215:::::eno1:dhcp"];
    initrd = {
      supportedFilesystems = [ "zfs" ];
      network = {
        enable = true;
        ssh = {
          enable = true;
          authorizedKeys = [ sshKeys.rkm ];
          hostKeys = [
            "/mnt/persistent/etc/ssh/ssh_host_rsa_key"
            "/mnt/persistent/etc/ssh/ssh_host_ed25519_key"
          ];
        };
      };
      preDeviceCommands = ''
        echo "zpool import -af; zfs load-key -a; killall zfs" >> /root/.profile
      '';
      postDeviceCommands = lib.mkAfter ''
       zfs rollback -r rpool/ephemeral/root@blank
      '';
      availableKernelModules = [
        "e1000e"
        "net"
        "xhci_pci"
        "ehci_pci"
        "ahci"
        "usbhid"
        "usb_storage"
        "sd_mod"
      ];
    };
  };

  networking = {
    # required for ZFS, generate with
    # cksum /etc/machine-id | while read c rest; do printf "%x" $c; done
    # or
    # head -c4 /dev/urandom | od -A none -t x4
    hostId = "63737ac9";
    hostName = "hoshijiro.maher.fyi";
    defaultGateway = "192.168.1.1";
    nameservers = [ "192.168.1.1" ];
    interfaces."wlp3s0" = {
      ipv4 = {
        addresses = [{
          address = "192.168.1.215";
          prefixLength = 24;
        }];
      };
    };
    wireless = {
      enable = true;
    };
    networkmanager = {
      enable = lib.mkOverride 1 false;
    };
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22 # ssh, sftp
        80 # http
        88 # Kerberos v5
        111 # NFS
        443 # https
        2049 # NFS
        config.services.nfs.server.mountdPort # NFS
        config.services.nfs.server.lockdPort # NFS lockd
        config.services.transmission.port
      ];
      allowedUDPPorts = [
        88 # Kerberos v5
        111 # NFS
        2049 # NFS
        config.services.nfs.server.mountdPort # NFS
        config.services.nfs.server.lockdPort # NFS
      ];
      allowedTCPPortRanges = [
        { from = 1714; to = 1764; } # KDE connect
      ];
      allowedUDPPortRanges = [
        { from = 1714; to = 1764; } # KDE connect
      ];
      trustedInterfaces = [ "lo" ];
      logRefusedPackets = true;
    };
    extraHosts = ''
        192.168.1.174 ayanami.maher.fyi
        127.0.0.1     hoshijiro.maher.fyi
      '';
  };

  services = {
    local = {
      pia-nm = {
        enable = false;
        inherit (secrets.services.local.pia-nm) username password;
      };
    };

    openssh = {
      enable = true;
      hostKeys = [
        {
          path = "/mnt/persistent/etc/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
        {
          path = "/mnt/persistent/etc/ssh/ssh_host_rsa_key";
          type = "rsa";
        }
      ];
      permitRootLogin = "yes";
    };

    fail2ban = {
      enable = true;
    };

    pcscd = {
      enable = true;
    };

    smartd = {
      enable = true;
    };

    openntpd = {
      enable = true;
      servers = [
        "0.jp.pool.ntp.org"
        "1.jp.pool.ntp.org"
        "2.jp.pool.ntp.org"
        "3.jp.pool.ntp.org"
      ];
    };

    # Resources:
    # http://rlworkman.net/howtos/NFS_Firewall_HOWTO
    #
    # Can mount in macOS like so:
    # sudo mount -o rw,bg,hard,resvport,intr,noac,nfc,tcp 192.168.56.10:/home/eqyiel/shared /Volumesghost/shared
    # You can also mount it in the Finder:  (command + k) nfs:/ghost:/home/eqyiel/shared
    nfs = {
      server = {
        enable = false;
        mountdPort = 32767;
        lockdPort = 32768;
        exports = ''
            # If UID and GIDs are not the same on the client and server you'll have
            # problems with permissions. However, you can force all access to occur as
            # a single user and group by combining the all_squash, anonuid, and
            # anongid export options. all_squash will map all UIDs and GIDs to the
            # anonymous user, and anonuid and anongid set the UID and GID of the
            # anonymous user.
            #
            # See: http://serverfault.com/a/241272
            #
            # macOS NEEDS the 'insecure' flag.  The the Darwin default is to assume
            # the nfs'ing will take place on an "insecure" port, i.e. > 1024, while
            # we're serving on 111.
            #
            # In the future, look into using users.groups.users.gid here (instead of
            # "100").  Right now it's being held back by
            # https://github.com/NixOS/nixpkgs/issues/17237 - until then, make sure
            # that anongid is the the same as users.groups.users.gid!
            /export 192.168.1.0/24(rw,async,no_subtree_check,no_root_squash,insecure)
          '';
      };
    };

    transmission = {
      enable = false;
      port = 9091;
      home = "/mnt/var/lib/${config.users.users.transmission.name}";
      settings = {
        download-dir = "${config.services.transmission.home}/download-dir";
        incomplete-dir = "${config.services.transmission.home}/incomplete-dir";
        incomplete-dir-enabled = true;
        rpc-whitelist = "127.0.0.1,192.168.*.*";
        rpc-whitelist-enabled = true;
        ratio-limit-enabled = true;
        ratio-limit = "2.0";
        upload-limit = "100";
        upload-limit-enabled = true;
        watch-dir = "${config.users.users.transmission.home}/watch-dir";
        watch-dir-enabled = true;
      };
    };

    resolved = {
      enable = true;
    };

    zfs = {
      autoSnapshot = {
        enable = true;
      };
      autoScrub = {
        enable = true;
      };
    };
  };

  console = {
    font = "Lat2-Terminus16";
    keyMap = "${pkgs.local-packages.custom-kbd}/share/keymaps/i386/qwerty/custom.map.gz";
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";
  };

  time = {
    timeZone = "Asia/Tokyo";
  };

  hardware = {
    enableAllFirmware = true;
    bluetooth = {
      enable = true;
    };
  };

  environment = {
    systemPackages = with pkgs; [
      pciutils
      zfs
      zfstools
      firefox
      # local-packages.nextcloud-client
      chromium
      mpv
      # libreoffice # broken on unstable
      python27Packages.syncthing-gtk
      kdeconnect
      lm_sensors
    ] ++ (import ./../../../common/package-lists/essentials.nix) {
      inherit pkgs;
    };

    etc = {
      "wpa_supplicant.conf" = {
        source = "/mnt/persistent/etc/wpa_supplicant.conf";
      };

      "secrets" = {
        source = "/mnt/persistent/etc/secrets";
      };
    };
  };

  programs = {
    zsh = {
      enable = true;
    };

    # automatically adds pkgs.android-udev-rules to services.udev.packages
    # to allow access, add users to "adbusers" group
    adb = {
      enable = true;
    };
  };

  nixpkgs =  {
    config = {
      allowUnfree = true;
    };
    overlays = [
      (import ../../../packages/overlay.nix)
    ];
  };

  nix = {
    # Use this if you want to force remote building
    # maxJobs = 0;
    trustedUsers = [ "root" ];
    nixPath = [
      "nixpkgs=${pkgs.callPackage ./lib/nixpkgs.nix {}}"
      "nixos-config=/etc/nixos/configuration.nix"
    ];

    gc = {
      automatic = false;
    };
  };

  security = {
    sudo = {
      wheelNeedsPassword = false;
    };
  };

  users = {
    mutableUsers = false;

    users = {
      root = {
        shell = pkgs.zsh;
        openssh.authorizedKeys.keys = [
          sshKeys.rkm
        ];
        inherit (secrets.users.users.root) initialPassword;
      };

      eqyiel = {
        home = "/home/${config.users.users.eqyiel.name}";
        createHome = true;
        isNormalUser = false;
        isSystemUser = false;
        extraGroups = [
          "wheel"
          "${config.users.groups.systemd-journal.name}"
          "adbusers"
        ];
        shell = pkgs.zsh;
        openssh.authorizedKeys.keys = [
          sshKeys.rkm
        ];
        inherit (secrets.users.users.eqyiel) initialPassword;
      };

      versapunk = {
        home = "/home/${config.users.users.versapunk.name}";
        createHome = true;
        isNormalUser = false;
        isSystemUser = false;
        shell = pkgs.zsh;
        inherit (secrets.users.users.versapunk) initialPassword;
      };
    };
  };

  documentation = {
    nixos = {
      enable = false;
    };
  };
}
