{ config, lib, pkgs, ... }:

let
  secrets = import ./secrets.nix;

  # TODO: this needs to have a separate A record
  fqdn = "maher.fyi";
in {
  imports = [ ../lib/matrix-appservice-irc-nixos ];

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
  };

  services.matrix-synapse = {
    dataDir = "/mnt/var/lib/matrix-synapse";
    create_local_database = false;
    allow_guest_access = false;
    bcrypt_rounds = "12";
    enable = true;
    web_client = false;
    enable_registration = false;
    registration_shared_secret = secrets.services.matrix-synapse.registration_shared_secret;
    server_name = fqdn;
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
      "turn:${fqdn}:3478?transport=udp"
      "turn:${fqdn}:3478?transport=tcp"
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
    realm = fqdn;
    cert = "/var/lib/acme/${fqdn}/fullchain.pem";
    pkey = "/var/lib/acme/${fqdn}/key.pem";
    min-port = 49152;
    max-port = 65535;
  };

  services.postgresql.enable = true;

  services.nginx = {
    enable = true;
    virtualHosts = {
      "maher.fyi" = {
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
    enable = true;
    url = "http://localhost:7555";
    port = 7555;
    homeserver_url = "http://localhost:8008";
    homeserver_domain = fqdn;
    stateDir = "/mnt/var/lib/matrix-appservice-irc";
    servers = {
      "irc.freenode.net" = {
        port = 6697;
        ssl = true;
        sslselfsign = false;
        password = null;
        sendConnectionMessages = true;
        botConfig_enabled = false;
        privateMessages_enabled = true;
        dynamicChannels_enabled = true;
        dynamicChannels_createAlias = true;
        dynamicChannels_published = true;
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
    ident_enabled = true;
    ident_port = 1113;
    logging_level = "debug";
    logging_logfile = null;
    logging_errfile = null;
    logging_toConsole = true;
    logging_maxFileSizeBytes = 134217728;
    logging_maxFiles = 5;
    statsd = null;
    databaseUri = "nedb:///mnt/var/lib/matrix-appservice-irc/data";
    passwordEncryptionKeyPath = null;
  };

  # This is not necessary if acme is enabled elsewhere for this fqdn.
  # services.nginx = {
  #   enable = true;
  #   virtualHosts."${fqdn}" = {
  #     serverName = fqdn;
  #     forceSSL = true;
  #     enableACME = true;
  #     acmeRoot = "/var/lib/acme/acme-challenge";
  #   };
  # };

  security.acme.certs."${fqdn}".postRun = "systemctl reload-or-restart matrix-synapse coturn";
}
