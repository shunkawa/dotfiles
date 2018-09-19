{ config, lib, pkgs, ...}:

with lib;

let
  cfg = config.services.gitlab-discord-bot;
in {
  options.services.gitlab-discord-bot = {
    enable = mkEnableOption "Enable Gitlab Discord bot";

    host = mkOption {
      type = types.str;
      default = "0.0.0.0";
      description = "Address to bind to.";
    };

    port = mkOption {
      type = types.str;
      default = "8080";
      description = "Port to serve on.";
    };

    webhookName = mkOption {
      type = types.str;
      description = "Name for the webhook.";
    };

    webhookURLFile = mkOption {
      type = types.str;
      description = "Path to file containing the webhook URL.";
    };

    webhookSecretFile = mkOption {
      type = types.str;
      description = ''
        Path to file containing the webhook secret.
      '';
    };

    user = mkOption {
      type = types.str;
      default = "gitlab-discord-bot";
      description = "User running the bot.";
    };

    group = mkOption {
      type = types.str;
      default = "gitlab-discord-bot";
      description = "User running the bot.";
    };
  };

  config = mkIf cfg.enable {
    users.users."${cfg.user}" = {
      name = cfg.user;
      group = cfg.group;
    };

    users.groups."${cfg.group}" = {
      name = cfg.group;
    };

    systemd.services."gitlab-discord-bot" = {
      enable = true;
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      environment = {
        PORT = "${toString cfg.port}";
        HOST = "${toString cfg.host}";
        WEBHOOK_NAME = cfg.webhookName;
      };
      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        ExecStart = (pkgs.writeScript "gitlab-discord-bot" ''
          #!${pkgs.stdenv.shell}
          export WEBHOOK_URL="$(<${cfg.webhookURLFile})"
          export WEBHOOK_SECRET="$(<${cfg.webhookSecretFile})"
          ${pkgs.local-packages.gitlab-discord-bot}/bin/gitlab-discord-bot
        '');
        Restart = "always";
        RestartSec = "3";
      };
      wantedBy = [ "multi-user.target" ];
    };
  };
}
