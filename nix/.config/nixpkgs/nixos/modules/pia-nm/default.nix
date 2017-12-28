{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.local--pia-nm;

in {

  options.services.local--pia-nm = {
    enable = mkEnableOption "PIA NetworkManager Config";
  };

  config = mkIf cfg.enable {
    environment.etc = lib.mapAttrs' (name: _: lib.nameValuePair
       "NetworkManager/system-connections/${name}"
       { source = "${pkgs.local-packages.pia-nm}/etc/NetworkManager/system-connections/${name}";
         # This sucks, but nm complains about default /nix/store permissions.
         mode = "0600";
       })
       (builtins.readDir
         "${pkgs.local-packages.pia-nm}/etc/NetworkManager/system-connections") // {
      "openvpn/pia-ca.rsa.4096.crt" = {
        source = "${pkgs.local-packages.pia-nm}/etc/openvpn/pia-ca.rsa.4096.crt";
        mode = "0600";
      };
    };
  };
}
