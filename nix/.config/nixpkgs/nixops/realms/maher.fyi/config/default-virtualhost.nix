{ ... }: {
  networking = {
   firewall = {
      enable = true;
      allowedTCPPorts = [
        80 443
      ];
    };
  };

  services.nginx = {
    enable = true;
    virtualHosts = {
      "_" = {
        default = true;
        locations = {
          "/.well-known/acme-challenge" = {
            root = "/var/lib/acme/acme-challenge";
          };
          "= /robots.txt" = {
            extraConfig = ''
              allow all;
              log_not_found off;
              access_log off;
            '';
          };
        };
      };
    };
  };
}
