let
    sshKeys = import ./../../../common/ssh-keys.nix;
    secrets = import ./secrets.nix;
in rec {
  network.description = "mx.maher.fyi";

  mx = { config, lib, pkgs, ... }: {
    imports = [
      ./config
    ] ++ (import ./../../../nixos/modules/module-list.nix);

    time.timeZone = "Adelaide/Australia";

    networking = {
      hostName = network.description;
      firewall = {
        enable = true;
        allowedTCPPorts = [
          22
        ];
        trustedInterfaces = [
          "lo"
        ];
      };
      extraHosts = ''
        127.0.0.1 mx.maher.fyi
      '';
    };

    services.openssh.enable = true;

    services.fail2ban.enable = true;

    services.journald.extraConfig = ''
      SystemMaxUse=1024M
    '';

    services.nixosManual.enable = false;

    services.prometheus.exporters.node = {
      enable = true;
      enabledCollectors = [
        "systemd"
        "diskstats"
        "filesystem"
        "loadavg"
        "meminfo"
        "netdev"
        "netstat"
        "stat"
        "time"
        "uname"
      ];
      openFirewall = false;
    };

    services.openntpd = {
      enable = true;
      servers = [
        "0.au.pool.ntp.org"
	      "1.au.pool.ntp.org"
	      "2.au.pool.ntp.org"
	      "3.au.pool.ntp.org"
      ];
    };

    security.sudo.wheelNeedsPassword = false;

    programs.zsh.enable = true;

    users.mutableUsers = false;

    users.users.root = {
      openssh.authorizedKeys.keys = [ sshKeys.rkm ];
      inherit (secrets.users.users.root) initialPassword;
    };

    users.users.eqyiel = (import ./secrets.nix).users.users.eqyiel // {
      extraGroups = [ "wheel" "${config.users.groups.systemd-journal.name}" ];
      group = "users";
      isNormalUser = true;
      openssh.authorizedKeys.keys = [ sshKeys.rkm ];
      shell = pkgs.zsh;
      inherit (secrets.users.users.eqyiel) initialPassword;
    };

    nix = {
      gc = {
        automatic = true;
        dates = "monthly";
        options = "--delete-older-than 31d";
      };
    };

    nixpkgs = {
      config.allowUnfree = true;
      overlays = [
        (import ../../../overlays/local-packages.nix)
      ];
    };

    system.stateVersion = "18.09pre";
  };
}
