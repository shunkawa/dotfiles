{ config, lib, pkgs, ... }:

with lib;

{
  # required for php's date.timezone
  time.timeZone = "Australia/Adelaide";

  networking.firewall = {
    enable = false;
    allowedTCPPorts = [ 80 ];
  };

  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
    ensureDatabases = [ "hannahi5_wo6241" "hannahi5_wo7027" ];
    ensureUsers = [{
      ensurePermissions = listToAttrs
        (map (dbName: { name = "${dbName}.*"; value = "ALL PRIVILEGES"; })
          config.services.mysql.ensureDatabases);
      name = "wordpress";
    }];
  };

  services.mysqlBackup = {
    enable = true;
    databases = [ "hannahi5_wo6241" "hannahi5_wo7027" ];
    location = "/data/backup/mysql";
    calendar = "daily";
  };

  services.httpd = let
    hostName = "hannahgoat.com";
  in {
    enable = true;
    adminAddr = "webmaster@example.com";
    logPerVirtualHost = false;
    listen = [{ ip = "*"; port = 80; }];
    extraConfig = ''
      LogLevel notice
      # NCSA extended/combined log format
      LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-agent}i\"" ncsa_extended
      # https://raymii.org/s/snippets/Apache_access_and_error_log_to_syslog.html
      CustomLog "||${pkgs.utillinux}/bin/logger -t apache -i -p local5.notice" ncsa_extended
      ErrorLog syslog:local6
      <IfModule dir_module>
        DirectoryIndex index.html index.php
      </IfModule>
    '';
    enablePHP = true;
    # php56 is no longer in nixpkgs
    phpPackage = (import (pkgs.callPackage ({ stdenv }:
      stdenv.mkDerivation {
        name = "nixpkgs";

        src = fetchGit {
          url = ../../../../../../../.nix-defexpr/nixpkgs;
          rev = "a8c71037e041725d40fbf2f3047347b6833b1703";
        };

        dontBuild = true;
        preferLocalBuild = true;

        installPhase = ''
          cp -a . $out
        '';
      }) {}) {}).pkgs.php56;

    virtualHosts = [{
      documentRoot = "/data/public_html";
      inherit hostName;
      extraConfig = ''
        RewriteEngine On
        RewriteCond %{HTTP_HOST} ^www\.(.+)$ [NC]
        RewriteRule ^(.*)$ https://%1$1 [R=301,L]

        <Directory "/data/public_html">
          DirectoryIndex index.php
          Allow from *
          Options FollowSymLinks
          AllowOverride All
        </Directory>
      '';
    }];
  };

  # Broken on unstable
  services.nixosManual.enable = false;

  system.nixos.stateVersion = "18.09pre";
}
