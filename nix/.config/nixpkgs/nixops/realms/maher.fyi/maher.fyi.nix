let
  host = "maher.fyi";
  sshKeys = import ./../../../common/ssh-keys.nix;
  secrets = import ./secrets.nix;
  accessKeyId = "personal-ec2-deployments";
  region = "ap-southeast-2";
  subnet = "subnet-4e95b207";

  mkConfig = ({ hostName }: mkOverride: (args@{ config, lib, pkgs, resources, ... }: lib.recursiveUpdate ({
    deployment.targetEnv = "ec2";
    deployment.owners = [ "ruben@maher.fyi" ];
    deployment.ec2.ebsBoot = true;
    deployment.ec2.instanceType = "t2.micro";
    deployment.ec2.securityGroups = [ "default" ];
    deployment.ec2.tags = { "PrometheusAutodiscover" = "true"; };
    deployment.ec2.ebsInitialRootDiskSize = 10;
    deployment.storeKeysOnMachine = false;
    deployment.ec2.accessKeyId = accessKeyId;
    deployment.ec2.region = region;
    deployment.ec2.keyPair = resources.ec2KeyPairs.personal-ec2-deployments;

    boot = {
      cleanTmpDir = true;
      kernel.sysctl = {
        "fs.inotify.max_user_watches" = 204800;
      };
      supportedFilesystems = [ "nfs4" ];
    };

    fileSystems."/data" = {
      fsType = "nfs";
      device = "172.31.33.221:/"; # efs
      options = [ "nfsvers=4.1" ];
    };

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

    time.timeZone = "Tokyo/Japan";

    services.openssh.enable = true;

    services.fail2ban.enable = true;

    services.journald.extraConfig = ''
      SystemMaxUse=1024M
    '';

    documentation.nixos.enable = false;

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
      package = pkgs.nixUnstable;
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

    system.stateVersion = "18.09";
  }) (mkOverride args)));

in {
  network.description = host;

  # Keep a GC root for the build
  network.enableRollback = true;

  mx = let hostName = "mx.${host}"; in (mkConfig {
    inherit hostName;
  } ({ ... }: {
    imports = [ (import ./config/mail-server.nix { inherit hostName; }) ];
    deployment.ec2.elasticIPv4 = "13.211.249.75";
    deployment.ec2.instanceType = "t2.nano";
  }));

  cloud = let hostName = "cloud.${host}"; in (mkConfig {
    inherit hostName;
  } ({ ... }: {
    imports = [
      (import ./config/nextcloud.nix { inherit hostName; })
      (import ./config/home.nix { inherit hostName; })
    ];
    deployment.ec2.elasticIPv4 = "13.238.250.196";
    deployment.ec2.instanceType = "t2.small";
  }));

  # Note: adding keypair a new region is a bit difficult.  You need to deploy
  # the keypair using the --include flag before you can actually use it to
  # deploy other resources.
  resources.ec2KeyPairs.personal-ec2-deployments = {
    inherit region accessKeyId;
  };
}
