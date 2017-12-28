{ config, lib, pkgs, ... }:

{
  home-manager.users = {
    eqyiel = lib.mkMerge [(import ../../../../home/config/syncthing {
      inherit lib pkgs;
      hostname = config.networking.hostName;
    })];
  };
}
