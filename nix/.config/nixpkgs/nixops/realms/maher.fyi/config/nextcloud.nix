{ hostName }: { config, lib, pkgs, ... }: let
  secrets = (import ./secrets.nix);
in {
  imports = [ ./default-virtualhost.nix ];

  services.nextcloud = {
    enable = true;
    inherit hostName;
    nginx.enable = true;
    https = true;
    autoconfig = {
      dbtype = "pgsql";
      dbname = "nextcloud";
      dbuser = "nextcloud";
      dbhost = "localhost";
      adminlogin = "nextcloud-admin";
      inherit (secrets.services.nextcloud.autoconfig) adminpass dbpass;
    };
    maxUploadSize = "512M";
    home = "/data/var/lib/nextcloud";
  };

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql96;
    dataDir = "/data/var/lib/postgresql/9.6";
    initialScript = pkgs.writeText "psql-init" ''
      create role nextcloud with login password '${secrets.services.nextcloud.autoconfig.dbpass}';
      create database nextcloud with owner nextcloud;
    '';
  };

  services.phpfpm.pools.nextcloud.extraConfig = ''
    pm = static;
    pm.max_children = 4
  '';

  deployment.keys.rclone-config-db-backups = {
    text = secrets.deployment.keys.rclone-config-db-backups;
    user = "root";
    group = "root";
    permissions = "0600";
  };

  fileSystems."/data" = {
    autoFormat = true;
    autoResize = true;
    device = "/dev/mapper/xvdf";
    ec2 = {
      cipher = "aes-cbc-essiv:sha256";
      encrypt = true;
      encryptionType = "luks";
      keySize = 256;
      size = 1024; # gigabytes
      volumeType = "sc1";
    };
    fsType = "ext4";
    options = ["_netdev"];
  };

  swapDevices = [ { device = "/swapfile"; size = 2 * 1024; }];

  environment.systemPackages = with pkgs; [ nextcloud-client ];

  services.nginx = {
    enable = true;
    virtualHosts = {
      "${hostName}" =  {
        forceSSL = true;
        enableACME = true;
      };
    };
  };

  users.users.nextcloud.uid = 1001;

  systemd.services."rclone-s3-db-backups" = {
    enable = true;
    description = "rclone-s3-db-backups";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    partOf = [ "network-fs.target" ];
    path = with pkgs; [ fuse ];
    serviceConfig =  {
      Type = "notify";
      ExecStart = "${pkgs.rclone}/bin/rclone mount db-backups-crypt: /backups --config=/run/keys/rclone-config-db-backups --cache-chunk-no-memory --cache-chunk-path /data/tmp/rclone --vfs-cache-mode full --crypt-show-mapping --log-level INFO --uid ${builtins.toString config.users.users.postgres.uid}  --default-permissions --allow-other";
      ExecStartPre = pkgs.writeScript "rclone-setup" ''
        #!${pkgs.stdenv.shell}
        mkdir -p /data/tmp/rclone
      '';
      ExecStop = "/run/wrappers/bin/fusermount -uz /backups";
      Restart = "always";
      RestartSec = "3";
    };
    wantedBy = [ "multi-user.target" ];
  };

  services.postgresqlBackup = {
    enable = true;
    databases = ["nextcloud"];
    location = "/backups/postgresql";
  };

  nixpkgs.config = {
    packageOverrides = pkgs: rec {
      nextcloud = pkgs.nextcloud.overrideAttrs (attrs: rec {
        name = "nextcloud-${version}";
        version = "14.0.0";
        src = pkgs.fetchurl {
          url = "https://download.nextcloud.com/server/releases/${name}.tar.bz2";
          sha256 = "0iwg7g2ydrs0ah5hxl9m5hqaz5wmymmdhiy997zbpap7hr1c2rgr";
        };
      });
    };
  };
}
