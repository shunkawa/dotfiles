{ hostName }: { config, lib, pkgs, ... }:

{
  imports = [
    "${((import <nixpkgs> {}).callPackage ../lib/home-manager.nix {})}/nixos"
  ];

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      22000 # syncthing
    ];
    allowedUDPPorts = [
      21027 # syncthing
    ];
  };

  users.users.eqyiel = {
    createHome = true;
    home = "/data/home/eqyiel";
  };

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
