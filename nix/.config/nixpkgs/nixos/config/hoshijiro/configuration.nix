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

  fileSystems."/" = {
    device = "/dev/mapper/vgroup-root";
    fsType = "ext4";
    options = [ "noatime" "nodiratime" "discard" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/A359-6573";
    fsType = "vfat";
  };

  # To create new zfs "filesystems":
  #
  # $ zfs create -o mountpoint=legacy tank/name-of-the-filesystem
  # $ zfs set atime=off tank/name-of-the-filesystem
  fileSystems."/mnt/media" = {
    options = [
      "nofail"
      "x-systemd.device-timeout=1"
    ];
    device = "tank-home/media";
    fsType = "zfs";
  };

  fileSystems."/mnt/var" = {
    options = [
      "nofail"
      "x-systemd.device-timeout=1"
    ];
    device = "tank-home/var";
    fsType = "zfs";
  };

  fileSystems."/mnt/home" = {
    options = [
      "nofail"
      "x-systemd.device-timeout=1"
    ];
    device = "tank-home/home";
    fsType = "zfs";
  };

  # This is a small ext4 formatted zvol to work around the error described here:
  # https://github.com/ValveSoftware/steam-for-linux/issues/4982#issuecomment-302834898
  #
  # TLDR:
  # zfs create -s -V 256G tank/steam
  # parted -s /dev/zvol/tank/steam mklabel gpt
  # parted /dev/zvol/tank/steam "mkpart primary 1 -1"
  # mkfs.ext4 /dev/zvol/tank/steam-part1
  # mount /dev/zvol/tank/steam-part1 /mnt/steam
  # mv ~/.local/share/Steam /mnt/steam
  # ln -s /mnt/steam/Steam ~/.local/share/Steam
  fileSystems."/mnt/steam" = {
    options = [
      "nofail"
      "x-systemd.device-timeout=1"
    ];
    device = "/dev/zvol/tank-home/steam-part1";
    fsType = "ext4";
  };

  fileSystems."/export/media" = {
    device = "/mnt/media";
    options = [ "bind" ];
  };

  fileSystems."/export/home" = {
    device = "/mnt/home";
    options = [ "bind" ];
  };

  fileSystems."/export/transmission" = {
    device = "/mnt/var/lib/transmission";
    options = [ "bind" ];
  };

  fileSystems."/mnt/server-media" = {
    options = [
      "nofail"
      "x-systemd.device-timeout=1"
    ];
    device = "tank/media";
    fsType = "zfs";
  };

  fileSystems."/mnt/server-var" = {
    options = [
      "nofail"
      "x-systemd.device-timeout=1"
    ];
    device = "tank/var";
    fsType = "zfs";
  };

  fileSystems."/mnt/server-home" = {
    options = [
      "nofail"
      "x-systemd.device-timeout=1"
    ];
    device = "tank/home";
    fsType = "zfs";
  };

  swapDevices = [{ device = "/dev/mapper/vgroup-swap"; }];

  powerManagement.cpuFreqGovernor = "powersave";

  boot = {
    zfs = {
      forceImportAll = false;
      forceImportRoot = false;
    };
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    cleanTmpDir = true;
    extraModulePackages = [ ];
    kernelModules = [ "kvm-intel" ];
    supportedFilesystems = [ "zfs" "nfs" "ntfs" ];
    # https://discourse.nixos.org/t/disk-encryption-on-nixos-servers-how-when-to-unlock/5030/11
    kernelParams = ["ip=192.168.1.216:::::eth0:"];
    initrd = {
      network = {
        enable = true;
        ssh = {
          enable = true;
          authorizedKeys = [ sshKeys.rkm ];
        };
      };
      postMountCommands = ''
        for int in /sys/class/net/*/
          do ip link set `basename $int` down
        done
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
      luks.devices = {
        root = {
          device = "/dev/disk/by-uuid/1d6b3cc6-56db-4031-9984-e323b83bca59";
          allowDiscards = true;
        };
        # Keyfile doesn't work here right now, see the nixpkgs issue about
        # single password unlocking.
        #
        # The crypttab generator does though, which is an OK workaround if you
        # don't actually need these devices for boot.
        #
        # Unfortunately it doesn't seem to work with ZFS, even if it's used
        # for non-root partitions.
        #
        # this means you have to enter a passphrase for each of these devices
        # during boot.  😿
        crypto_zfs_00 = {
          device = "/dev/disk/by-uuid/1c3851fc-c1de-4860-806f-4609801f5fb9";
          preLVM = false;
          # keyFile = "/root/tank.keyfile";
        };
        crypto_zfs_01 = {
          device = "/dev/disk/by-uuid/7065dce3-1be4-4cae-b7c2-4dc4e1bf0f23";
          preLVM = false;
          # keyFile = "/root/tank.keyfile";
        };
        # from datacenter
        crypto_zfs_02 = {
          device = "/dev/disk/by-uuid/2e59e4cf-cfb2-42dd-9bdb-b6da0f031c18";
          preLVM = false;
        };
        crypto_zfs_03 = {
          device = "/dev/disk/by-uuid/1c634e3c-05aa-4b86-91c4-2a309c5475a6";
          preLVM = false;
        };
      };
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
      ipv4.addresses = [{
        address = "192.168.1.215";
        prefixLength = 24;
      }];
    };
    wireless.enable = true;
    networkmanager.enable = lib.mkOverride 1 false;
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

  services.local.pia-nm = {
    enable = false;
    inherit (secrets.services.local.pia-nm) username password;
  };

  console.font = "Lat2-Terminus16";
  console.keyMap = "us";

  i18n = {
    defaultLocale = "en_US.UTF-8";
  };

  time.timeZone = "Asia/Tokyo";

  hardware.enableAllFirmware = true;
  hardware.bluetooth.enable = true;

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
  };

  services.openssh.enable = true;
  services.openssh.permitRootLogin = "yes";

  services.fail2ban.enable = true;

  services.pcscd.enable = true;

  services.smartd.enable = true;

  services.openntpd = {
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
  services.nfs.server = {
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

  services.transmission = {
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

  services.resolved = { enable = true; };

  programs.zsh.enable = true;

  # automatically adds pkgs.android-udev-rules to services.udev.packages
  # to allow access, add users to "adbusers" group
  programs.adb.enable = true;

  nixpkgs =  {
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
      "nixpkgs=${pkgs.callPackage ./lib/nixpkgs.nix {}}"
      "nixos-config=/etc/nixos/configuration.nix"
    ];
  };

  security.sudo.wheelNeedsPassword = false;

  # TODO, enable automatic login for users in nopasswdlogin group
  # security.pam.services = {
  #   gdm-password.text = ''
  #     auth sufficient pam_succeed_if.so user ingroup nopasswdlogin
  #     ${config.security.pam.services.gdm-password.text}
  #   '';
  # };
  #
  # users.groups = {
  #   # users in this group can bypass the GDM password prompt
  #   nopasswdlogin.members = [ config.users.users.normie.name ];
  # };

  users.mutableUsers = false;

  users.users = {
    root = {
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = [
        sshKeys.rkm
      ];
      inherit (secrets.users.users.root) initialPassword;
    };

    eqyiel = {
      home = "/mnt/home/${config.users.users.eqyiel.name}";
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
      home = "/mnt/home/${config.users.users.versapunk.name}";
      createHome = true;
      isNormalUser = false;
      isSystemUser = false;
      shell = pkgs.zsh;
      inherit (secrets.users.users.versapunk) initialPassword;
    };
  };

  nix.gc.automatic = false;

  documentation.nixos.enable = false;
}
