{ config, lib, pkgs, ... }: let
  secrets = (import ./secrets.nix);
  hostName = "cloud.maher.fyi";
in {
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
      adminpassFile = secrets.deployment.keys.nextcloud-adminpass-file;
    };
    maxUploadSize = "512M";
    home = "/mnt/server-var/new/cloud.maher.fyi/var/lib/nextcloud";
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
    dataDir = "/mnt/server-var/new/cloud.maher.fyi/var/lib/postgresql/9.6";
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
      chown redis:${config.services.nginx.group} /var/run/redis
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
      chown redis:${config.services.nginx.group} /var/run/redis/redis.sock
    '';
    after = [ "redis.service" ];
    requires = [ "redis.service" ];
    wantedBy = [ "redis.service" ];
    serviceConfig = {
      Type = "oneshot";
    };
  };

  # deployment.keys.nextcloud-adminpass-file = {
  #   text = secrets.deployment.keys.nextcloud-adminpass-file;
  #   user = "nextcloud";
  #   group = "nginx";
  #   permissions = "0600";
  # };

  security.acme = {
    email = "ruben@maher.fyi";
    acceptTerms = true;
  };

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
}
