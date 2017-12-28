{ config, lib, pkgs, ... }:

let
  secrets = import ./secrets.nix;
  hostname = "rsvp.fyi";
  robotsTxt = pkgs.writeText "robots.txt" ''
    User-agent: *
    Disallow: /
  '';
  pgUser = "rsvp.fyi";
  pgDatabase = "rsvp.fyi";
  pgPassword = secrets.pgPassword;
  pgPort = "5432";
  pgHost = "127.0.0.1";
  serverHost = "127.0.0.1";
  serverPassword = secrets.serverPassword;
  serverPort = 12344;
  clientPkg = pkgs.local-packages.rsvp-fyi."rsvp.fyi-client";
  serverPkg = pkgs.local-packages.rsvp-fyi."rsvp.fyi-server";

in {
  services.nginx.virtualHosts =
    let
      virtualhostConfig = {
        forceSSL = true;
        enableACME = true;
        locations = {
          "/robots.txt" = {
            extraConfig = ''
              alias ${robotsTxt};
            '';
          };
          # "/api" = {
          #   proxyPass = "http://127.0.0.1:12344";
          # };
          "/" = {
            root = "${clientPkg}";
            extraConfig = "try_files $uri $uri/ /index.html;";
          };
        };
      };
    in {
      "${hostname}" = virtualhostConfig;
      "www.${hostname}" = {
        enableACME = true;
        forceSSL = true;
        locations = {
          "/" = {
            extraConfig = "return 301 $scheme://${hostname}$request_uri;";
          };
        };
      };
    };
  # services.postgresql.enable = true;

  # systemd.services."${hostname}-server" = {
  #    after = [ "network.target" "nginx.service" "postgresql.service" ];
  #    environment = {
  #      PGUSER = "${pgUser}";
  #      PGDATABASE = "${pgDatabase}";
  #      PGPASSWORD = "${pgPassword}";
  #      PGPORT = "${toString pgPort}";
  #      PGHOST = "${pgHost}";
  #      PGMAXCLIENTS = "10";
  #      PGIDLETIMEOUTMILLIS = "30000";
  #      HOST = "${serverHost}";
  #      PORT = "${toString serverPort}";
  #      PASSWORD = "${serverPassword}";
  #    };
  #    serviceConfig = {
  #      Type = "simple";
  #      Restart = "always";
  #      RestartSec = "300";
  #      ExecStart = "${serverPkg}/bin/rsvp.fyi-server";
  #    };
  #    enable = true;
  # };
}
