{ config, lib, pkgs, ... }:
let
  sshKeys = {
    rkm = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDpGxQqrPj/uDrY1EZ+QpR0fRKg1mybkTT+vxpnqth2Bg+GjuCS/cqHuLoUlvN6QV/bRf194hxzsFIW2QUEs5KWfMcZnFpXX+y+mLhGhzun+OocorHn5jPMTlUNy8ruGunto+O8whaHaDcbX8FokH/MU1H3i5busH/fq/vOE7mVKNaJNcRC6U8al8NldkTHhaIEyViDAMbE5EQiuhzznUwdnRGj3ntk68l2WxVnUAwvLUs2nH5wYX+5N35IycRMT4bkY5i9CHpB4dpO7Tve7Y3JfmacA4jb2BQVpRI346s8H4kTV1+1gszV/3xtoVgekBCgxxRnNObmO9MA1xmIcTZH cardno:000603822873";
  };
in
rec {
  imports = [
    <home-manager/nixos>
    ./config/default-virtualhost.nix
    ./config/nextcloud.nix
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

    "/mnt/persistent/media" = {
      device = "tank/persistent/media";
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

    "/var/lib/postgresql" = {
      device = "/mnt/persistent/var/lib/postgresql";
      options = [ "bind" ];
    };

    "/export/media" = {
      device = "/mnt/persistent/media";
      options = [ "bind" ];
    };
  };

  swapDevices = [{ device = "/dev/disk/by-uuid/d810ed98-18b6-46f5-8724-366e5bde060b"; }];

  systemd = {
    tmpfiles = {
      rules = [
        "L /var/lib/acme - - - - /mnt/persistent/var/lib/acme"
        "L /var/lib/bluetooth - - - - /mnt/persistent/var/lib/bluetooth"
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
    extraModulePackages = [ ];
    kernelModules = [ "kvm-intel" ];
    supportedFilesystems = [ "zfs" "nfs" "ntfs" ];
    kernelParams = [ "acpi=off" ];
    initrd = {
      supportedFilesystems = [ "zfs" ];
      # network = {
      #   enable = true;
      #   ssh = {
      #     enable = true;
      #     authorizedKeys = [ sshKeys.rkm ];
      #     hostKeys = [
      #       "/mnt/persistent/etc/ssh/ssh_host_rsa_key"
      #       "/mnt/persistent/etc/ssh/ssh_host_ed25519_key"
      #     ];
      #   };
      # };
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
    hostName = "hoshijiro";
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
      extraConfig = ''
        # This is required in order to automatically remove files like
        # /run/user/1000/gnupg/S.gpg-agent file after disconnecting, which is
        # what you want if you use agent forwarding.
        # https://github.com/drduh/YubiKey-Guide/tree/6e2109ea464d9caeae141a05574dd031156238dd#remote-machines-agent-forwardings
        StreamLocalBindUnlink yes
      '';
    };

    fail2ban = {
      enable = true;
    };

    pcscd = {
      enable = true;
    };

    smartd = {
      enable = true;
      notifications.test = true;
      notifications.mail.enable = true;
      notifications.mail.sender = "root@hoshijiro.maher.fyi";
      notifications.mail.recipient = "ruben@maher.fyi";
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
    # Can mount in from macOS using Finder: (command + k) nfs://192.168.1.215/export/media
    nfs = {
      server = {
        enable = true;
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
          # macOS NEEDS "insecure" to be able to mount from Finder: https://apple.stackexchange.com/questions/142697/why-does-mounting-an-nfs-share-from-linux-require-the-use-of-a-privileged-port
          /export/media 192.168.1.0/24(rw,async,insecure,no_subtree_check,all_squash,anonuid=${builtins.toString config.users.users.nobody.uid},anongid=${builtins.toString config.users.groups.nogroup.gid})
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
      lm_sensors
      pciutils
      smartmontools
      zfs
      zfstools
    ];

    etc = {
      "wpa_supplicant.conf" = {
        source = "/mnt/persistent/etc/wpa_supplicant.conf";
      };

      "secrets" = {
        source = "/mnt/persistent/etc/secrets";
      };
    };

    pathsToLink = [
      # Almost everything is installed in the user profile, but this is required
      # so that home manager can link everything under
      # /etc/profiles/per-user/$USER.
      "/"
    ];
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

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
    overlays = [
      (import ../../../overlays/emacs-overlay.nix)
      (import ../../../overlays/local-packages.nix)
    ];
  };

  nix = {
    # Use this if you want to force remote building
    # maxJobs = 0;
    trustedUsers = [ "root" ];
    nixPath = [
      "home-manager=${import ./lib/home-manager.nix}"
      "nixos-config=/etc/nixos/configuration.nix"
      "nixpkgs=${import ./lib/nixpkgs.nix}"
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
        # The file should contain exactly one line, which should be the password
        # in an encrypted form that is suitable for the chpasswd -e command.
        # Create one like:
        # nix-shell -p mkpasswd --command 'mkpasswd -m sha-512'
        passwordFile = "/etc/static/secrets/users/root/password-file";
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
        # The file should contain exactly one line, which should be the password
        # in an encrypted form that is suitable for the chpasswd -e command.
        # Create one like:
        # nix-shell -p mkpasswd --command 'mkpasswd -m sha-512'
        passwordFile = "/etc/static/secrets/users/eqyiel/password-file";
      };
    };
  };

  home-manager.users.eqyiel = import ../../../home.nix;
  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;

  users.users.ssmtp = {
    createHome = false;
    isNormalUser = false;
    isSystemUser = true;
    extraGroups = [
      "${config.users.groups.systemd-journal.name}"
    ];
  };

  services.ssmtp = {
    # This file is one line of plain text, with a trailing newline
    authPassFile = "/etc/secrets/ssmtp/ruben@maher.fyi";
    authUser = "ruben@maher.fyi";
    hostName = "smtp.fastmail.com:465";
    domain = "hoshijiro.maher.fyi";
    enable = true;
    setSendmail = true;
    settings = { Debug = true; };
    useSTARTTLS = false;
    useTLS = true;
  };

  services.restic.backups = {
    nextcloud = {
      initialize = true;
      # This file is one line of plain text, with a trailing newline
      passwordFile = "/etc/secrets/backups/nextcloud-password-file";
      # This file looks like
      # [b2]
      # type = b2
      # account = aaaaaaaaaaaaaaaaaaaaaaaaa
      # key = aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
      # hard_delete = true
      rcloneConfigFile = "/etc/secrets/backups/rclone-config-file";
      paths = [ "/var/lib/nextcloud/" ];
      extraBackupArgs = [
        "--exclude=/var/lib/nextcloud/data/appdata_*"
        "--exclude=/var/lib/nextcloud/.rnd"
      ];
      pruneOpts = [
        "--keep-daily 1"
        "--keep-weekly 7"
        "--keep-monthly 4"
        "--keep-yearly 12"
      ];
      # backups-4c5d9cfe-e605-4838-8f59-4526198a341e should be the name of a
      # bucket that already exists.
      repository = "rclone:b2:backups-4c5d9cfe-e605-4838-8f59-4526198a341e/nextcloud";
      timerConfig = {
        OnCalendar = "00:05";
        RandomizedDelaySec = "5h";
      };
    };
  };

  services.local.systemd-status-mail = {
    enable = true;
    services = [
      "restic-backups-nextcloud.service"
      "acme-cloud.maher.fyi.service"
    ];
    fqdn = "hoshijiro.maher.fyi";
    recipient = "ruben@maher.fyi";
  };

  documentation = {
    nixos = {
      enable = false;
    };
  };
}
