let
  sshKeys = import ./../../../common/ssh-keys.nix;
  secrets = import ./secrets.nix;
  accessKeyId = "personal-ec2-deployments";
  region = "ap-southeast-2";

  mkConfig = (hostName: mkOverride: (args@{ config, lib, pkgs, resources, ... }: lib.recursiveUpdate {
    deployment.targetEnv = "ec2";
    deployment.owners = [ "ruben@maher.fyi" ];
    deployment.ec2.accessKeyId = accessKeyId;
    deployment.ec2.region = region;
    deployment.ec2.ebsBoot = true;
    deployment.ec2.instanceType = "t2.micro";
    deployment.ec2.securityGroups = [ "default" ];
    deployment.ec2.keyPair = resources.ec2KeyPairs.personal-ec2-deployments;
    deployment.ec2.tags = { "PrometheusAutodiscover" = "true"; };
    deployment.ec2.ebsInitialRootDiskSize = 10;
    deployment.storeKeysOnMachine = false;

    fileSystems."/data" = {
      autoFormat = true;
      device = "/dev/mapper/xvdf";
      ec2 = {
        cipher = "aes-cbc-essiv:sha256";
        encrypt = true;
        encryptionType = "luks";
        keySize = 256;
        size = 50; # gigabytes
      };
      fsType = "ext4";
    };

    imports = [
      ./../../../nixos/modules/module-list.nix
    ];

    time.timeZone = "Adelaide/Australia";

    networking = {
      inherit hostName;
      firewall = {
        enable = true;
        allowedTCPPorts = [
          22
        ];
        trustedInterfaces = [
          "lo"
        ];
      };
      extraHosts = ''
        127.0.0.1 ${hostName}
      '';
    };

    services.openssh.enable = true;

    services.fail2ban.enable = true;

    services.journald.extraConfig = ''
      SystemMaxUse=1024M
    '';

    services.nixosManual.enable = false;

    services.prometheus.exporters.node = {
      enable = true;
      enabledCollectors = [
        "systemd"
        "diskstats"
        "filesystem"
        "loadavg"
        "meminfo"
        "netdev"
        "netstat"
        "stat"
        "time"
        "uname"
      ];
      openFirewall = false;
    };

    # EC2 has its own NTP server provided by the hypervisor
    # services.openntpd = {
    #   enable = true;
    #   servers = [
    #     "0.au.pool.ntp.org"
	  #     "1.au.pool.ntp.org"
	  #     "2.au.pool.ntp.org"
	  #     "3.au.pool.ntp.org"
    #   ];
    # };

    security.sudo.wheelNeedsPassword = false;

    programs.zsh.enable = true;

    users.mutableUsers = false;

    users.users.root = {
      openssh.authorizedKeys.keys = [ sshKeys.rkm ];
      inherit (secrets.users.users.root) initialPassword;
    };

    users.users.eqyiel = (import ./secrets.nix).users.users.eqyiel // {
      extraGroups = [ "wheel" "${config.users.groups.systemd-journal.name}" ];
      group = "users";
      isNormalUser = true;
      openssh.authorizedKeys.keys = [ sshKeys.rkm ];
      shell = pkgs.zsh;
      inherit (secrets.users.users.eqyiel) initialPassword;
    };

    nix = {
      gc = {
        automatic = true;
        dates = "monthly";
        options = "--delete-older-than 31d";
      };
    };

    nixpkgs = {
      config.allowUnfree = true;
      overlays = [
        (import ../../../overlays/local-packages.nix)
      ];
    };

    system.stateVersion = "18.09pre";
  } (mkOverride args)));

in rec {
  network.description = "maher.fyi";

  # Keep a GC root for the build
  network.enableRollback = true;

  mx = let hostName = "mx.${network.description}"; in (mkConfig hostName ({ ... }: {
    imports = [ (import ./config/mail-server.nix { inherit hostName; }) ];
    deployment.ec2.elasticIPv4 = "13.211.249.75";
    deployment.ec2.instanceType = "t2.nano";
  }));

  resources.ec2KeyPairs.personal-ec2-deployments = {
    inherit accessKeyId;
    inherit region;
  };
}
