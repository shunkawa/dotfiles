{ config, lib, pkgs, ... }:

{
  imports = [ ./pulseaudio.nix ];

  security.pam.services.gdm.enableGnomeKeyring = true;

  networking.networkmanager = {
    enable = true;
    packages = [
      pkgs.gnome3.networkmanager_openvpn
    ];
    # TODO: Check out this thread on the mailing list which discusses a similar problem
    # Message-Id: <8a8f40ef-cc33-4b39-ac83-1285fe22c37f@googlegroups.com>
    # Also this one on GitHub:
    # Subject: [NixOS/nixpkgs] Enrich PATH of networkmanager dispatcher (#39468)
    # dispatcherScripts = [
    #   # Each script receives two arguments, the first being the interface name
    #   # of the device an operation just happened on, and second the action.
    #   #
    #   # See: man 8 networkmanager
    #   { # Update transmission's port forwarding assignment
    #     type = "basic";
    #     source = pkgs.writeScript "update-transmission-port-forwarding-assignment" ''
    #       #!${pkgs.bash}/bin/bash

    #       set -euo pipefail

    #       INTERFACE="''${1}"
    #       ACTION="''${2}"

    #       TEMP_FILE="$(${pkgs.coreutils}/bin/mktemp)"

    #       cleanup() {
    #       ${pkgs.coreutils}/bin/rm "''${TEMP_FILE}"
    #       }

    #       trap 'cleanup' EXIT

    #       if [[ "''${ACTION}" == "vpn-up" ]]; then
    #       CONFIG_FILE="${config.users.users.transmission.home}/.config/transmission-daemon/settings.json"
    #       PORT="$(${localPackages.get-pia-port-forwarding-assignment}/bin/get-pia-port-forwarding-assignment | ${pkgs.jq}/bin/jq '.port')"
    #       echo "Rewritten config: $(${pkgs.jq}/bin/jq --arg PORT "''${PORT}" '.["peer-port"] = $PORT')"
    #       ${pkgs.jq}/bin/jq --arg PORT "''${PORT}" '.["peer-port"] = $PORT' < "''${CONFIG_FILE}" > "''${TEMP_FILE}"

    #       echo "Received port assignment of ''${PORT} for ''${INTERFACE}, reloading transmission daemon."

    #       ${pkgs.coreutils}/bin/mv "''${TEMP_FILE}" "''${CONFIG_FILE}"
    #       ${pkgs.coreutils}/bin/chmod 600 "''${CONFIG_FILE}"
    #       ${pkgs.coreutils}/bin/chown transmission:transmission "''${CONFIG_FILE}"

    #       ${pkgs.systemd}/bin/systemctl reload transmission.service
    #       fi
    #     '';
    #   }
    # ];
  };

  environment = {
    gnome3.excludePackages = [
      # gnome-software is fixed in
      # https://github.com/NixOS/nixpkgs/commit/6a17c5a46c933deb6c856be8602ea9f5d6560e98
      # but probably doesn't do anything useful with nixos anyway, at least before
      # something like this is done:
      # RFC: Generating AppStream Metadata #15932:
      # https://github.com/NixOS/nixpkgs/issues/15932
      pkgs.gnome3.gnome-software
      pkgs.gnome3.evolution
      pkgs.gnome3.epiphany
      pkgs.gnome3.totem
    ];

    systemPackages = with pkgs; [
      firefox
      flac
      gnome-mpv
      gnome3.gnome-boxes
      gnomeExtensions.caffeine
      gnomeExtensions.clipboard-indicator
      gnomeExtensions.mediaplayer
      gnomeExtensions.topicons-plus
      grip
      lame
      vlc
      # local-packages.nautilus-python
      # local-packages.indicator-kdeconnect
    ];

    etc."xdg/gtk-3.0/settings.ini" = {
      text = ''
        [Settings]
        gtk-key-theme-name = Emacs
      '';
      };
  };

  services.xserver = {
    enable = true;
    layout = "us";
    libinput = {
      enable = true;
      tapping = true;
    };
    xkbOptions = "caps:hyper";
    displayManager.gdm = {
      enable = true;
    };
    desktopManager.gnome3 = {
      enable = true;
      extraGSettingsOverridePackages = with pkgs; [
        gnome3.gnome_settings_daemon
        gnome3.gnome_terminal
      ];
      extraGSettingsOverrides = ''
        [org.gnome.desktop.screensaver]
        lock-delay=3600
        lock-enabled=true

        [org.gnome.desktop.session]
        idle-delay=900

        [org.gnome.settings-daemon.plugins.power]
        power-button-action='nothing'
        idle-dim=true
        sleep-inactive-battery-type='nothing'
        sleep-inactive-ac-timeout=3600
        sleep-inactive-ac-type='nothing'
        sleep-inactive-battery-timeout=1800

        [org.gnome.desktop.input-sources]
        show-all-sources=true
        sources=[('xkb', 'us'), ('ibus', 'mozc-jp'), ('ibus', 'uniemoji')]
        xkb-options=['caps:hyper']

        [org.gnome.desktop.interface]
        gtk-key-theme='Emacs'

        [org.gnome.desktop.privacy]
        remember-app-usage=false
        remember-recent-files=false
        remove-old-temp-files=true
        remove-old-trash-files=true
        report-technical-problems=false
        send-software-usage-stats=false

        [org.gnome.desktop.wm.preferences]
        focus-mode='sloppy'

        [org.gnome.terminal.legacy.profiles:.:b1dcc9dd-5262-4d8d-a863-c897e6d979b9]
        background-color='rgb(0,43,54)'
        scrollbar-policy='never'
        palette=['rgb(7,54,66)', 'rgb(220,50,47)', 'rgb(133,153,0)', 'rgb(181,137,0)', 'rgb(38,139,210)', 'rgb(211,54,130)', 'rgb(42,161,152)', 'rgb(238,232,213)', 'rgb(0,43,54)', 'rgb(203,75,22)', 'rgb(88,110,117)', 'rgb(101,123,131)', 'rgb(131,148,150)', 'rgb(108,113,196)', 'rgb(147,161,161)', 'rgb(253,246,227)']
        foreground-color='rgb(131,148,150)'
        use-theme-colors=false

        [org.gnome.terminal.legacy]
        theme-variant='dark'
        schema-version=uint32 3
      '';
    };
  };

  nixpkgs.config.firefox.enableGnomeExtensions = true;

  sound = {
    # disabled by default since 18.03
    enable = true;
    mediaKeys.enable = true;
  };

  i18n.inputMethod = {
    enabled = "ibus";
    ibus.engines = with pkgs.ibus-engines; [ pkgs.local-packages.ibus-engines.mozc uniemoji ];
  };
}
