{ config, lib, pkgs, ... }:

{
  home-manager.users = {
    eqyiel = lib.mkMerge [
      (import ../../../../home/config/syncthing {
        inherit lib pkgs;
        actualHostname = config.networking.hostName;
      })
      (import ../../../../home/config/urlwatch)
    ];
  };
}
