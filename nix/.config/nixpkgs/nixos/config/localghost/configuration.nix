# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

let

  localPackages = (import ./../../pkgs/all-packages.nix) {
    inherit config lib pkgs;
  };

  sshKeys = import ./../../common/ssh-keys.nix;

  # Hostname of the host machine.
  hostMachineHostName = "hanekawa";

  # Static IP address of the host machine (vboxnet0).
  hostMachineIPAddress = "192.168.56.1";

  # Interface that corresponds to host only adapter in virtualbox.
  hostOnlyInterface = "enp0s8";

  # Static IP address that will be assigned to this machine.
  guestMachineIPAddress = "192.168.56.10";

  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/installer/tools/tools.nix#L10
  makeProg = args: pkgs.substituteAll (args // {
    dir = "bin";
    isExecutable = true;
  });

in
rec {
  imports = [
    ./hardware-configuration.nix
    ./../../pkgs/overrides.nix
  ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    initrd.luks.devices = [{
      name = "root";
      device = "/dev/sda3";
      allowDiscards = true;
    }];
    # NFSD won't start with ipv6 disabled
    # kernelParams = [ "ipv6.disable=1" ];
    kernel.sysctl = { "fs.inotify.max_user_watches" = 524288; };
    kernelModules = [ "snd-seq" "snd-rawmidi" ];
    kernelParams = [ "irqpoll" ];
    kernelPackages = pkgs.linuxPackages_4_8;
  };

  networking = {
    hostName = "localghost";
    enableIPv6 = false;
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22 # SSH
        80 # HTTP
        111 # NFS
        443 # HTTPS
        2049 # NFS
        services.nfs.server.mountdPort # NFS
        services.nfs.server.lockdPort # NFS lockd
        22000 # syncthing
      ];
      allowedUDPPorts = [
        111 # NFS
        2049 # NFS
        services.nfs.server.mountdPort # NFS
        services.nfs.server.lockdPort # NFS
        21027 # syncthing
      ];
      trustedInterfaces = [ "lo" ];
    };
    interfaces = {
      "${hostOnlyInterface}" = {
        ip4 = [{
          address = guestMachineIPAddress;
          prefixLength = 24;
        }];
      };
    };
    extraHosts = ''
      ${hostMachineIPAddress} ${hostMachineHostName}
    '';
  };

  i18n = {
    consoleFont = "Lat2-Terminus16";
    defaultLocale = "en_US.UTF-8";
    consoleUseXkbConfig = true;
    supportedLocales = [ "en_US.UTF-8/UTF-8" ];
  };

  time.timeZone = "Australia/Adelaide";

  environment.systemPackages = with pkgs; [
    firefox
    awscli
    mpv
    localPackages.fontcustom

    (makeProg {
      name = "reset-ohci-drivers";
      src = (writeScript "reset-ohci-drivers" ''
        #!${pkgs.stdenv.shell}
        # Forcefully reset USB drivers (useful when Yubikey vanishes from
        # virtualbox guest).
        sudo rmmod ohci_pci
        sudo rmmod ohci_hcd
        sudo rmmod ehci_pci
        sudo rmmod ehci_hcd
        sudo modprobe ohci_pci
        sudo modprobe ohci_hcd
        sudo modprobe ehci_pci
        sudo modprobe ehci_hcd
      '');
    })

    (makeProg {
      name = "fix-resolution";
      src = (writeScript "fix-resolution" ''
        #!${pkgs.stdenv.shell}
        # Temporary solution to get full 5k screen resolution in virtualbox
        # guest.
        xrandr --newmode "5120x2880_60.00" 1276.50  5120 5560 6128 7136  2880 2883 2888 2982 -hsync +vsync
        xrandr --addmode VGA-1 5120x2880_60.00
        xrandr --output VGA-1 --mode 5120x2880_60.00
      '');
    })

    # TODO: make this more platform independent, for example try local
    # xsel/xcopy or pbcopy if they're available before piping it through SSH.
    (makeProg {
      name = "copy-to-clipboard";
      src = (writeScript "copy-to-clipboard" ''
        #!${stdenv.shell}
        # GNU netcat doesn't have the -q flag, which is essential here
        cat | ${pkgs.netcat-openbsd}/bin/nc -q0 127.0.0.1 2224
      '');
    })
  ] ++
  (import ./../../common/package-lists/essentials.nix) {
    inherit pkgs localPackages;
  } ++
  (import ./../../common/package-lists/x11-tools.nix) {
    inherit pkgs localPackages;
  };

  fonts.fonts = (import ./../../common/package-lists/fonts.nix) {
    inherit pkgs localPackages;
  };

  # see here for whether we can override resolution
  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/virtualisation/qemu-vm.nix#L490
  services.xserver = {
    enable = false;
    layout = "us";
    libinput.enable = true;
    synaptics.enable = false;
    xkbOptions = "caps:hyper";
    exportConfiguration = true; # for xkbcomp
    displayManager.gdm = {
      enable = false;
      autoLogin = {
        enable = true;
        user = "eqyiel";
      };
    };
    desktopManager.gnome3 = {
      enable = false;
    };

    # it's possible to add the full 5k resolution like so, but it looks kind of
    # bad in GNOME at the moment:
    # xrandr --newmode "5120x2880_60.00" 1276.50  5120 5560 6128 7136  2880 2883 2888 2982 -hsync +vsync
    # xrandr --addmode VGA-1 5120x2880_60.00
    # xrandr --output VGA-1 --mode 5120x2880_60.00
  };

  services.gnome3 = {
    seahorse.enable = false; # Don't start GPG agent automatically
    tracker.enable = false; # Don't turn my computer into a space heater
  };

  services.syncthing = {
    user = "eqyiel";
    group = "users";
    enable = true;
    useInotify = true;
    dataDir = "/var/lib/syncthing";
  };

  # Resources:
  # http://rlworkman.net/howtos/NFS_Firewall_HOWTO
  #
  # Can mount in macOS like so:
  # sudo mount -o rw,bg,hard,resvport,intr,noac,nfc,tcp 192.168.56.10:/home/eqyiel/shared /Volumes/localghost/shared
  # You can also mount it in the Finder:  (command + k) nfs://localghost:/home/eqyiel/shared
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
      /home/eqyiel/shared ${hostMachineHostName}(rw,all_squash,anonuid=${toString users.users.eqyiel.uid},anongid=100,insecure)
      /home/eqyiel/git/mango-chutney ${hostMachineHostName}(rw,all_squash,anonuid=${toString users.users.eqyiel.uid},anongid=100,insecure)
    '';
  };

  # Add ${guestMachineIPAddress} to the host's hostfile to access these
  # virtualhosts.
  services.httpd = {
    enable = true;
    user = "www-data";
    group = "www-data";
    phpOptions = ''
      upload_max_filesize = 10G;
    '';
    port = 443;
    enableSSL = true;
    sslServerCert = "/var/lib/httpd/fullchain.pem";
    sslServerKey = "/var/lib/httpd/key.pem";
    enablePHP = true;
    phpPackage = pkgs.php56;
    adminAddr = "pleb@localghost";
    hostName = "localghost";
    extraModules = [ "filter" ];
    logPerVirtualHost = true;
    extraConfig = ''
      LogLevel debug
      <IfModule dir_module>
        DirectoryIndex index.html index.php
      </IfModule>
    '';
    virtualHosts = [{
      documentRoot = "/home/eqyiel/shared/www";
      enableSSL = true;
      port = 443;
      extraConfig = ''
       Header set Access-Control-Allow-Origin "*"
       Header set Access-Control-Allow-Methods "GET, POST, PUT, OPTIONS"
       <Directory "/home/eqyiel/shared/www">
         Allow from all
         AllowOverride All
         # Options -Indexes
       </Directory>
      '';
      hostName = "localghost";
    }];
  };

  systemd.services."${networking.hostName}-selfsigned" =
    let
      certificatePath = "/var/lib/httpd";
      rights = "744";
      user = "www-data";
      group = "www-data";
    in {
      enable = true;
      description = "Create preliminary self-signed certificate for ${networking.hostName}";
      preStart = ''
        if [ ! -d '${certificatePath}' ]
        then
          mkdir -p '${certificatePath}'
          chmod ${rights} '${certificatePath}'
          chown '${user}:${group}' '${certificatePath}'
        fi
      '';
      script = ''
        # Create self-signed key
        workdir="/run/${networking.hostName}-selfsigned"
        ${pkgs.openssl.bin}/bin/openssl genrsa -des3 -passout pass:x -out $workdir/server.pass.key 2048
        ${pkgs.openssl.bin}/bin/openssl rsa -passin pass:x -in $workdir/server.pass.key -out $workdir/server.key
        ${pkgs.openssl.bin}/bin/openssl req -new -key $workdir/server.key -out $workdir/server.csr \
          -subj "/C=UK/ST=Warwickshire/L=Leamington/O=OrgName/OU=IT Department/CN=*"
        ${pkgs.openssl.bin}/bin/openssl x509 -req -days 1 -in $workdir/server.csr -signkey $workdir/server.key -out $workdir/server.crt
        # Move key to destination
        mv $workdir/server.key ${certificatePath}/key.pem
        mv $workdir/server.crt ${certificatePath}/fullchain.pem
        # Clean up working directory
        rm $workdir/server.csr
        rm $workdir/server.pass.key
        # Give key acme permissions
        chmod ${rights} '${certificatePath}/key.pem'
        chown '${user}:${group}' '${certificatePath}/key.pem'
        chmod ${rights} '${certificatePath}/fullchain.pem'
        chown '${user}:${group}' '${certificatePath}/fullchain.pem'
      '';
      serviceConfig = {
        Type = "oneshot";
        RuntimeDirectory = "${networking.hostName}-selfsigned";
        PermissionsStartOnly = true;
        User = user;
        Group = group;
      };
      unitConfig = {
        # Do not create self-signed key when key already exists
        ConditionPathExists = "!${certificatePath}/key.pem";
      };
      before = [
        "httpd.service"
      ];
      after = [
        "network.target"
      ];
      wantedBy = [
        "multi-user.target"
      ];
  };

  services.pcscd = {
    enable = true; # yubikey
    plugins = [ pkgs.ccid ];
  };

  services.openssh = {
    enable = true;
    forwardX11 = true;
  };

  services.dovecot2 = {
    enable = true;
    mailLocation = "maildir:~/mail:LAYOUT=fs";
    enablePop3 = false;
    enableImap = true;
    extraConfig = ''
      listen = *
    '';
  };

  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
    extraOptions = ''
      max_allowed_packet=128M
    '';
  };

  virtualisation.virtualbox.guest.enable = true;

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
  nixpkgs.config.allowUnfree = true;

  security.sudo.wheelNeedsPassword = false;

  environment.shells = [ pkgs.bashInteractive pkgs.zsh ];

  programs.zsh.enable = true;

  users.mutableUsers = false;

  users.users = {
    eqyiel = {
      isNormalUser = true;
      uid = 1000;
      initialPassword = (import ./secrets.nix).users.users.eqyiel.initialPassword;
      shell = pkgs.zsh;
      extraGroups = [
       "audio"
       "networkmanager"
       "systemd-journal"
       "wheel"
      ];
      openssh.authorizedKeys.keys = [
        sshKeys.rkm
      ];
    };
    root = {
      openssh.authorizedKeys.keys = [
        sshKeys.rkm
      ];
    };
    www-data = {
      isNormalUser = false;
      group = "www-data";
      home = "/var/www";
      useDefaultShell = true;
      createHome = true;
    };
  };

  users.groups.www-data.name = "www-data";

  system.stateVersion = "16.09";
}
