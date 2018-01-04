{ lib, pkgs, ... }:

{
  home.file.".config/urlwatch/urlwatch.yaml".source = pkgs.writeText "urlwatch.yaml" (builtins.toJSON {
    display = {
      error = true;
      new = true;
      unchanged = false;
    };
    report = {
      email = {
        enabled = true;
        from = "ruben@maher.fyi";
        to = "ruben@maher.fyi";
        method = "sendmail";
        sendmail = {
          path = "/run/wrappers/bin/sendmail";
        };
      };
    };
  });

  home.file.".config/urlwatch/urls.yaml".source = pkgs.writeText "urls.yaml" ''
    kind: url
    url: https://jpf.org.au/language/for-learners/jlpt/
    filter: element-by-class:wpb_wrapper
    ---
    kind: url
    url: http://jafa.asn.au/index.php/jlpt
    filter: element-by-class:item-page
    ---
    kind: url
    url: https://pypi.python.org/pypi/awsebcli
    filter: element-by-id:changelog
  '';

  systemd.user = {
    services.urlwatch = {
      Unit = {
        Description = "Run urlwatch";
        After = [ "network.target" ];
      };

      Service = {
        Type = "forking";
        ExecStart = "${pkgs.urlwatch}/bin/urlwatch";
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };

    timers.urlwatch = {
      Unit = {
        Description = "Run urlwatch";
        PartOf = [ "urlwatch.service" ];
      };

      Timer = {
        OnCalendar = "hourly";
      };

      Install = {
        WantedBy = [ "timers.target" ];
      };
    };
  };
}
