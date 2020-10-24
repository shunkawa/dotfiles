{ config, lib, pkgs, ... }:
let
  cfg = config.services.local.systemd-status-mail;

  mkService = { serviceName, parentServiceName, fqdn, recipient }: {
    name = serviceName;
    value = {
      description = "Send status email for ${parentServiceName}.service";
      after = [ "${parentServiceName}.service" ];
      wantedBy = [ "${parentServiceName}.service" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.writeScriptBin "send-status-email" ''
          #!${pkgs.stdenv.shell}
          status="[FAILURE]"

          if ! (systemctl is-failed ${parentServiceName}.service 2>&1 >/dev/null); then
            status="[SUCCESS]"
          fi

          /run/wrappers/bin/sendmail -t <<EOF
          To: ${recipient}
          From: systemd <root@${fqdn}>
          Subject: $status ${parentServiceName}.service
          Content-Transfer-Encoding: 8bit
          Content-Type: text/plain; charset=UTF-8

          $(systemctl status --full "${parentServiceName}.service")
          EOF
        ''}/bin/send-status-email";
      };
    };
  };
in
{
  options = {
    services.local.systemd-status-mail = {
      enable = lib.mkEnableOption "systemd-status-mail";

      services = lib.mkOption {
        default = [ ];
        description = ''
          List of services to bind to (including ".service" suffix).
        '';
      };

      fqdn = lib.mkOption {
        type = lib.types.str;
        default = null;
        description = ''
          Fully qualified domain name of this server.
        '';
      };

      recipient = lib.mkOption {
        type = lib.types.str;
        default = null;
        description = ''
          User to send mail to.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services = lib.listToAttrs
      (map
        (service:
          let
            parentServiceName = lib.removeSuffix ".service" service;
            serviceName = "systemd-status-mail-${parentServiceName}";
          in
          mkService
            {
              inherit parentServiceName;
              inherit serviceName;
              inherit (cfg) fqdn recipient;
            }
        )
        cfg.services
      );
  };
}
