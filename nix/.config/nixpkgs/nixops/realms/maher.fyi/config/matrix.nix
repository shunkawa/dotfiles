{ hostName }: { config, lib, pkgs, ... }:

let
  secrets = import ./secrets.nix;
in {
  imports = [
    "${((import <nixpkgs> {}).callPackage ../lib/matrix-appservice-irc-nixos.nix {})}"
    ./default-virtualhost.nix
  ] ++ (import ./../../../../nixos/modules/module-list.nix);

  fileSystems."/data" = {
    autoFormat = true;
    autoResize = true;
    device = "/dev/mapper/xvdf";
    ec2 = {
      cipher = "aes-cbc-essiv:sha256";
      encrypt = true;
      encryptionType = "luks";
      keySize = 256;
      size = 100; # gigabytes
    };
    fsType = "ext4";
  };

  deployment.keys.rclone-config-db-backups = {
    text = secrets.deployment.keys.rclone-config-db-backups;
    user = "root";
    group = "root";
    permissions = "0600";
  };

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql96;
    dataDir = "/data/var/lib/postgresql/9.6";
    initialScript = pkgs.writeText "psql-init" ''
      create user synapse with login password '${secrets.services.matrix-synapse.database_args.password}';
      create database "matrix-synapse" encoding 'UTF8' LC_COLLATE='C' LC_CTYPE='C' template=template0 owner synapse;
    '';
  };

  systemd.services."rclone-s3-db-backups" = {
    enable = true;
    description = "rclone-s3-db-backups";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    partOf = [ "network-fs.target" ];
    path = with pkgs; [ fuse ];
    serviceConfig =  {
      Type = "notify";
      ExecStart = "${pkgs.rclone}/bin/rclone mount db-backups-crypt: /backups --config=/run/keys/rclone-config-db-backups --vfs-cache-mode full --crypt-show-mapping --log-level INFO --uid ${builtins.toString config.users.users.postgres.uid}  --default-permissions --allow-other";
      ExecStartPre = pkgs.writeScript "rclone-setup" ''
        #!${pkgs.stdenv.shell}
        mkdir -p /data/tmp/rclone
        mkdir -p /backups
      '';
      ExecStop = "/run/wrappers/bin/fusermount -uz /backups";
      Restart = "always";
      RestartSec = "3";
    };
    wantedBy = [ "multi-user.target" ];
  };

  systemd.services.postgresql.after = [ "rclone-s3-db-backups.service" ];

  services.local.postgresqlBackup = {
    enable = true;
    databases = ["matrix-synapse"];
    location = "/backups/postgresql";
  };

  networking.firewall = {
    allowedTCPPorts = [
      1113 # matrix-appservice-irc ident
      3478 # coturn
      8448 # matrix
      7555 # matrix-appservice-irc
    ];
    allowedUDPPorts = [
      3478 # coturn
    ];
    allowedUDPPortRanges = [
      { from = 49152; to = 65535; } # coturn
    ];
    trustedInterfaces = [ "lo" ];
    logRefusedPackets = true;
  };

  services.matrix-synapse = {
    dataDir = "/data/var/lib/matrix-synapse";
    create_local_database = false;
    allow_guest_access = false;
    bcrypt_rounds = "12";
    enable = true;
    web_client = false;
    enable_registration = false;
    registration_shared_secret = secrets.services.matrix-synapse.registration_shared_secret;
    # If using a SRV record to find synapse, this should be
    # the domain that the SRV record is attached to:
    # https://github.com/matrix-org/synapse/tree/43ecfe0b1028fea5e4dda197f5631aed67182ee6#setting-up-federation
    # _matrix._tcp.maher.fyi. 3600    IN      SRV     10 0 8448 matrix.maher.fyi.
    server_name = "maher.fyi";
    database_type = "psycopg2";
    database_args = {
      user = "synapse";
      password = secrets.services.matrix-synapse.database_args.password;
      database = "matrix-synapse";
      host = "localhost";
      cp_min = "5";
      cp_max = "10";
    };
    turn_uris = [
      "turn:turn.maher.fyi:3478?transport=udp"
      "turn:turn.maher.fyi:3478?transport=tcp"
    ];
    # This needs to be the same as services.coturn.static-auth-secret
    turn_shared_secret = secrets.services.matrix-synapse.turn_shared_secret;
    turn_user_lifetime = "24h";
    url_preview_enabled = true;
    listeners = [
      {
        port = 8448;
        bind_address = "";
        type = "http";
        tls = true;
        x_forwarded = false;
        resources = [
          { names = ["client" "webclient"]; compress = true; }
          { names = ["federation"]; compress = false; }
        ];
      }
      {
        port = 8008;
        bind_address = "";
        type = "http";
        tls = false;
        x_forwarded = false;
        resources = [
          { names = ["client" "webclient"]; compress = true; }
          { names = ["federation"]; compress = false; }
        ];
      }];
  };

  services.coturn = {
    enable = true;
    lt-cred-mech = true;
    static-auth-secret = secrets.services.coturn.static-auth-secret;
    realm = "turn.maher.fyi";
    cert = "/var/lib/acme/turn.maher.fyi/fullchain.pem";
    pkey = "/var/lib/acme/turn.maher.fyi/key.pem";
    min-port = 49152;
    max-port = 65535;
  };

  services.nginx = {
    enable = true;
    virtualHosts = {
      "turn.maher.fyi" = {
        forceSSL = true;
        enableACME = true;
      };
      "matrix.maher.fyi" = {
        forceSSL = true;
        enableACME = true;
        locations = {
          "/_matrix" = {
            proxyPass = "https://127.0.0.1:8448/_matrix";
          };
          "= /robots.txt" = {
            extraConfig = ''
              allow all;
              log_not_found off;
              access_log off;
            '';
          };
        };
      };
    };
  };

  services.matrix-appservice-irc = {
    # broken at the moment
    # https://github.com/matrix-org/matrix-appservice-irc/issues/689
    enable = false;
    url = "http://${hostName}:7555";
    port = 7555;
    homeserver_url = "http://${hostName}:8008";
    homeserver_domain = hostName;
    stateDir = "/data/var/lib/matrix-appservice-irc";
    servers = {
      "irc.freenode.net" = {
        port = 6697;
        ssl = true;
        sslselfsign = false;
        sasl = true;
        password = secrets.services.matrix-appservice-irc.servers."chat.freenode.net".password;
        sendConnectionMessages = true;
        botConfig_enabled = false;
        botConfig_nick = "e73a9188-d157-43";
        botConfig_password = secrets.services.matrix-appservice-irc.servers."chat.freenode.net".botConfig_password;
        privateMessages_enabled = true;
        dynamicChannels_enabled = true;
        dynamicChannels_createAlias = true;
        dynamicChannels_published = false;
        dynamicChannels_joinRule = "invite";
        dynamicChannels_whitelist = [ "@eqyiel:maher.fyi" ];
        dynamicChannels_federate = false;
        dynamicChannels_aliasTemplate = "#irc_$SERVER_$CHANNEL";
        dynamicChannels_exclude = [];
        membershipLists_enabled = true;
        membershipLists_global_ircToMatrix = {
          initial = true;
          incremental = true;
        };
        membershipLists_global_matrixToIrc = {
          initial = true;
          incremental = true;
        };
        membershipLists_rooms = [];
        membershipLists_channels = [];
        mappings = {};
        matrixClients_userTemplate = "@irc_$NICK";
        matrixClients_displayName = "$NICK (IRC)";
        ircClients_nickTemplate = "$DISPLAY";
        ircClients_allowNickChanges = true;
        ircClients_maxClients = 30;
        ircClients_ipv6_prefix = null;
        ircClients_idleTimeout = 172800;
      };
    };
    ident_enabled = false;
    logging_level = "debug";
    logging_logfile = null;
    logging_errfile = null;
    logging_toConsole = true;
    logging_maxFileSizeBytes = 134217728;
    logging_maxFiles = 5;
    statsd = null;
    databaseUri = "nedb:///data/var/lib/matrix-appservice-irc/data";
    passwordEncryptionKeyPath = null;
  };

  security.acme.certs."matrix.maher.fyi".postRun = "systemctl reload-or-restart matrix-synapse coturn";
  security.acme.certs."turn.maher.fyi".postRun = "systemctl reload-or-restart matrix-synapse coturn";
}
