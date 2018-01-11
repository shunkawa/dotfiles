{ config, lib, pkgs, ... }:

{
  security.pam.services.gdm.enableGnomeKeyring = true;

  networking.networkmanager = {
    enable = true;
    packages = [
      pkgs.gnome3.networkmanager_openvpn
    ];
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
    ];

    pathsToLink = [
      "/share/emacs"   # Necessary for emacs support files (mu4e)
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
      extraGSettingsOverrides = ''
        [org/gnome/desktop/input-sources]
        show-all-sources=true
        sources=[('xkb', 'us')]
        xkb-options=['caps:hyper']

        [org/gnome/desktop/interface]
        gtk-key-theme='Emacs'

        [org/gnome/gnome-screenshot]
        last-save-directory='file:///home/eqyiel'
      '';
    };
  };

  i18n.inputMethod = {
    enabled = "ibus";
    ibus.engines = with pkgs.ibus-engines; [ anthy ];
  };
}
