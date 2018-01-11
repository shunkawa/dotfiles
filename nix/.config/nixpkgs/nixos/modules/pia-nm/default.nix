{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.local.pia-nm;

in {
  options.services.local.pia-nm = {
    enable = mkEnableOption "PIA NetworkManager Config";

    username = mkOption {
      type = types.str;
      description = ''
        PIA username.

        NOTE THAT THIS WILL BE WORLD READABLE IN THE NIX STORE.
      '';
    };

    password = mkOption {
      type = types.str;
      description = ''
        PIA password.

        NOTE THAT THIS WILL BE WORLD READABLE IN THE NIX STORE.
      '';
    };
  };

  config = mkIf cfg.enable {
    environment.etc = lib.mapAttrs' (name: _: lib.nameValuePair
      "NetworkManager/system-connections/${name}" {
       source = pkgs.runCommand "${name}" {} ''
         cp "${pkgs.local-packages.pia-nm}/etc/NetworkManager/system-connections/${name}" $out

         # /i means append lines before
         ${pkgs.gnused}/bin/sed -i "/\[ipv4\]/i \
         \[vpn-secrets\]\n\
         password=${cfg.password}\n" $out

         # /a means append lines after
         ${pkgs.gnused}/bin/sed -i "/\[vpn\]/a \
         username=${cfg.username}" $out
       '';
        mode = "0600";
      }) (builtins.readDir "${pkgs.local-packages.pia-nm}/etc/NetworkManager/system-connections") // {
      "openvpn/pia-ca.rsa.4096.crt" = {
        source = "${pkgs.local-packages.pia-nm}/etc/openvpn/pia-ca.rsa.4096.crt";
        mode = "0600";
      };
    };
  };
}
