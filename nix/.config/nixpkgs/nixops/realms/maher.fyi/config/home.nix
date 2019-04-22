{ hostName }: { config, lib, pkgs, ... }: rec {
  imports = [
    "${((import <nixpkgs> {}).callPackage ../lib/home-manager.nix {})}/nixos"
    ./default-virtualhost.nix
  ] ++ (import ./../../../../nixos/modules/module-list.nix);

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      21 # FTP
      22 # SSH, SFTP
      22000 # syncthing
    ];
    allowedUDPPorts = [
      21027 # syncthing
    ];
  };

  services.nginx = {
    enable = true;
    virtualHosts = {
      "nadiah.maher.fyi" = {
        forceSSL = true;
        enableACME = true;
        root = "${config.users.users.nadiah.home}/public_html";
        locations."= /robots.txt".extraConfig = ''
          return 200 "User-agent: *\nDisallow: /\n";
        '';
      };
    };
  };

  users.users = {
    eqyiel = {
      createHome = true;
      home = "/data/cloud.maher.fyi/home/eqyiel";
      isSystemUser = false;
      useDefaultShell = true;
      extraGroups = [ "wheel" "nginx" "journal" ];
    };
    nadiah = (import ./secrets.nix).users.users.nadiah // {
      createHome = true;
      home = "/data/cloud.maher.fyi/home/nadiah";
      isSystemUser = false;
      useDefaultShell = true;
      extraGroups = [ "wheel" "nginx" "journal" ];
    };
  };

  systemd.services."home-manager-eqyiel".after = [ "data.mount" ];

  # Don't forget to enable linger in order for user services to keep running.
  # Alternatively, move this to a user service.
  # https://github.com/NixOS/nixpkgs/issues/3702
  home-manager = {
    users = {
      eqyiel = lib.mkMerge [
        {
          # https://github.com/rycee/home-manager/issues/254
          manual.manpages.enable = false;
        }
        (import ../../../../home/config/syncthing {
          inherit lib pkgs;
          actualHostname = hostName;
        })
        (import ../../../../home/config/urlwatch)
      ];
    };
  };
}
