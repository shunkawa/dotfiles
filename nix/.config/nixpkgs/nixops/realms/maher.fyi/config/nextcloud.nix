{ hostName }: { config, lib, pkgs, ... }: let
  secrets = (import ./secrets.nix);
in {
  imports = [
    ./default-virtualhost.nix
  ] ++ (import ./../../../../nixos/modules/module-list.nix);

  services.nextcloud = {
    enable = true;
    inherit hostName;
    nginx.enable = true;
    https = true;
    caching = {
      apcu = false;
      redis = true;
      memcached = false;
    };
    config = {
      dbtype = "pgsql";
      dbname = "nextcloud";
      dbuser = "nextcloud";
      dbhost = "localhost";
      inherit (secrets.services.nextcloud.autoconfig) dbpass;
      adminuser = "nextcloud-admin";
      adminpassFile = "/run/keys/nextcloud-adminpass-file";
    };
    maxUploadSize = "512M";
    home = "/data/cloud.maher.fyi/var/lib/nextcloud";
  };

  systemd.services.nextcloud-setup = {
    requires = ["postgresql.service"];
    after = [
      "postgresql.service"
      "chown-redis-socket.service"
    ];
    preStart = ''
      mkdir -p ${config.services.nextcloud.home}
      chown nextcloud:${config.services.nginx.group} ${config.services.nextcloud.home}
    '';
  };

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql96;
    dataDir = "/data/cloud.maher.fyi/var/lib/postgresql/9.6";
    initialScript = pkgs.writeText "psql-init" ''
      create role nextcloud with login password '${secrets.services.nextcloud.autoconfig.dbpass}';
      create database nextcloud with owner nextcloud;
    '';
  };

  services.redis = {
    unixSocket = "/var/run/redis/redis.sock";
    enable = true;
    extraConfig = ''
      unixsocketperm 770
    '';
  };

  systemd.services.redis = {
    preStart = ''
      mkdir -p /var/run/redis
      chown ${config.services.redis.user}:${config.services.nginx.group} /var/run/redis
    '';
    serviceConfig.PermissionsStartOnly = true;
  };

  systemd.services."chown-redis-socket" = {
    enable = true;
    script = ''
      until ${pkgs.redis}/bin/redis-cli ping; do
        echo "waiting for redis..."
        sleep 1
      done
      chown ${config.services.redis.user}:${config.services.nginx.group} /var/run/redis/redis.sock
    '';
    after = [ "redis.service" ];
    requires = [ "redis.service" ];
    wantedBy = [ "redis.service" ];
    serviceConfig = {
      Type = "oneshot";
    };
  };

  deployment.keys.nextcloud-adminpass-file = {
    text = secrets.deployment.keys.nextcloud-adminpass-file;
    user = "nextcloud";
    group = "nginx";
    permissions = "0600";
  };

  users.users.nextcloud.extraGroups = [ "keys" ];

  deployment.keys.rclone-config-db-backups = {
    text = secrets.deployment.keys.rclone-config-db-backups;
    user = "root";
    group = "root";
    permissions = "0600";
  };

  swapDevices = [ { device = "/swapfile"; size = 2 * 1024; }];

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
      ExecStart = "${pkgs.rclone}/bin/rclone mount db-backups-s3:cloud.maher.fyi-db-backups /backups --config=/run/keys/rclone-config-db-backups --cache-chunk-no-memory --cache-chunk-path /data/cloud.maher.fyi/tmp/rclone --vfs-cache-mode full --log-level INFO --uid ${builtins.toString config.users.users.postgres.uid}  --default-permissions --allow-other";
      ExecStartPre = pkgs.writeScript "rclone-setup" ''
        #!${pkgs.stdenv.shell}
        mkdir -p /data/cloud.maher.fyi/tmp/rclone
        mkdir -p /backups
      '';
      ExecStop = "/run/wrappers/bin/fusermount -uz /backups";
      Restart = "always";
      RestartSec = "3";
    };
    wantedBy = [ "multi-user.target" ];
  };

  services.local.postgresqlBackup = {
    enable = true;
    databases = ["nextcloud"];
    location = "/backups/postgresql";
  };
}
