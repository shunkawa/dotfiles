{ hostName }: { config, lib, pkgs, ... }:

let
  secrets = import ./secrets.nix;
in rec {
  imports = [
    ./default-virtualhost.nix
  ] ++ (import ./../../../../nixos/modules/module-list.nix);

  services.nginx = {
    virtualHosts = {
      "discord.shitpost.digital" = {
        forceSSL = true;
        enableACME = true;
        locations = {
          "/" = {
            proxyPass = "http://127.0.0.1:${config.services.gitlab-discord-bot.port}";
          };
        };
      };
    };
  };

  services.gitlab-discord-bot = {
    enable = true;
    port = "8080";
    host = "0.0.0.0";
    webhookName = "bmg";
    webhookURLFile = "/run/keys/gitlab-discord-bot-webhook-url";
    webhookSecretFile = "/run/keys/gitlab-discord-bot-webhook-secret";
    user = "gitlab-discord-bot";
    group = "gitlab-discord-bot";
  };

  # This is for the sake of being able to read its own files in the /run/keys
  # directory (a nixops thing).
  users.users."${config.services.gitlab-discord-bot.user}".extraGroups = [ "keys" ];

  deployment.keys = {
    gitlab-discord-bot-webhook-secret = {
      text = secrets.deployment.keys.gitlab-discord-bot-webhook-secret;
      user = config.services.gitlab-discord-bot.user;
      group = config.services.gitlab-discord-bot.group;
      permissions = "0600";
    };

    gitlab-discord-bot-webhook-url = {
      text = secrets.deployment.keys.gitlab-discord-bot-webhook-url;
      user = config.services.gitlab-discord-bot.user;
      group = config.services.gitlab-discord-bot.group;
      permissions = "0600";
    };
  };
}
