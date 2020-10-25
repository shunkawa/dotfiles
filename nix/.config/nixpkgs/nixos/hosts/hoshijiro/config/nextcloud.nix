{ config, lib, pkgs, ... }:
let
  hostName = "cloud.maher.fyi";
in
{
  services.nextcloud = {
    enable = true;
    hostName = "cloud.maher.fyi";
    https = true;
    caching = {
      # Note that this only enables the module, you still need to configure it
      # in config.php:
      # https://docs.nextcloud.com/server/20/admin_manual/configuration_server/caching_configuration.html
      apcu = true;
      redis = true;
      memcached = false;
    };
    config = {
      dbtype = "pgsql";
      dbname = "nextcloud";
      dbuser = "nextcloud";
      dbhost = "localhost";
      dbpassFile = "/etc/secrets/nextcloud/dbpass-file";
      adminuser = "nextcloud-admin";
      adminpassFile = "/etc/secrets/nextcloud/adminpass-file";
    };
    maxUploadSize = "512M";
    home = "/var/lib/nextcloud";
  };

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql96;
    dataDir = "/var/lib/postgresql/9.6";
    # postgres users has to have read and execute permission to every directory
    # leading up to this one, and read permission to the file itself.
    # root@hoshijiro> ls -lha /mnt/persistent/etc/secrets/postgres
    # total 22K
    # drw-r-x--- 2 root postgres   3 May  7 09:45 .
    # drwxr-xr-x 4 root root       4 May  7 09:44 ..
    # -rw-r----- 1 root postgres 158 May  7 09:45 psql-init
    initialScript = "/etc/secrets/postgres/psql-init";
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
      chown ${config.users.users.redis.name}:${config.services.nginx.group} /var/run/redis
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
      chown ${config.users.users.redis.name}:${config.users.groups.nextcloud.name} /var/run/redis/redis.sock
    '';
    after = [ "redis.service" ];
    requires = [ "redis.service" ];
    wantedBy = [ "redis.service" ];
    serviceConfig = {
      Type = "oneshot";
    };
  };

  security.acme = {
    email = "ruben@maher.fyi";
    acceptTerms = true;
  };

  services.nginx = {
    enable = true;
    virtualHosts = {
      "cloud.maher.fyi" = {
        forceSSL = true;
        enableACME = true;
      };
    };
  };

  users.users.nextcloud.uid = 1001;
}
