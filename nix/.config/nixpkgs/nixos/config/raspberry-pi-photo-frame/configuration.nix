{ pkgs, lib, ... }:

let
  picturesMountDir = "/mnt/nextcloud";

  nixpkgsSrc = builtins.fetchGit {
    name = "nixos-unstable-2019-08-12";
    url = https://github.com/nixos/nixpkgs/;
    rev = "62509f72cf143fcce09b02e6828ddb96503f7c18";
  };

  nixpkgs = import nixpkgsSrc {
    overlays = [
      (self: super: {
        local-packages = {
          kbd = super.callPackage ({ stdenv, kbd }: stdenv.mkDerivation {
            name = "custom-kbd";
            buildInputs = [ kbd ];
            phases = [ "installPhase" ];
            installPhase = ''
              mkdir -p $out/share/keymaps/i386/qwerty
              zcat ${kbd}/share/keymaps/i386/qwerty/us.map.gz > $out/share/keymaps/i386/qwerty/custom.map
              cat ${kbd}/share/keymaps/i386/include/linux-with-two-alt-keys.inc >> $out/share/keymaps/i386/qwerty/custom.map
              # No such keysym as Hyper by default, so abuse another VT102
              # definition.  Emacs needs to be configured to decode this.
              #
              # Something like this.  I don't know if it works:
              # (define-key input-decode-map "\e[35~" [(f21)])
              # (define-key key-translation-map (kbd "<f21>") 'event-apply-hyper-modifier)
              # https://www.emacswiki.org/emacs/LinuxConsoleKeys
              echo 'string F21 = "\033[35~"' >> $out/share/keymaps/i386/qwerty/custom.map
              echo 'keycode 58 = F21' >> $out/share/keymaps/i386/qwerty/custom.map
              gzip $out/share/keymaps/i386/qwerty/custom.map
            '';
          }) {};
        };
      })
    ];
  };

  pkgs = nixpkgs.pkgs;

  lib = nixpkgs.lib;
in {
  imports = [ "${nixpkgsSrc}/nixos/modules/installer/cd-dvd/sd-image-aarch64.nix" ];

  nix.nixPath = [ "nixpkgs=${nixpkgsSrc}" "nixos-config=/etc/nixos/configuration.nix" ];

  # installation-device.nix (which is imported by sd-image-aarch64.nix) disables
  # these units.
  systemd.services.sshd.wantedBy = lib.mkOverride 1 [ "multi-user.target" ];
  systemd.services.wpa_supplicant.wantedBy = lib.mkOverride 1 [ "multi-user.target" ];
  services.nixosManual.showManual = lib.mkOverride 1 false;
  services.mingetty.autologinUser = lib.mkOverride 1 null;
  documentation = {
    enable = lib.mkOverride 1 false;
    nixos.enable = lib.mkOverride 1 false;
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_rpi;
    consoleLogLevel = 0;
    kernelParams = [
      # suppress blinking cursor from drawing over framebuffer
      "vt.global_cursor_default=0"
      # print any kernel messages to tty3, not tty0 (prevent drawing over framebuffer)
      "console=tty3"
    ];
  };

  environment.systemPackages = with pkgs; [
    tmux
    emacs
    gitAndTools.gitFull
    ripgrep
    fd
  ];

  # Passphrase is managed statefully in /etc/wpa_supplicant.conf in
  # order to keep it out of /nix/store.
  # $ wpa_passphrase <ssid> [passphrase] > /etc/wpa_supplicant.conf
  networking.wireless.enable = true;
  systemd.services.wpa_supplicant.enable = true;
  networking.enableIPv6 = false;

  hardware = {
    enableRedistributableFirmware = true;
  };

  services.openssh = {
    enable = true;
    permitRootLogin = lib.mkOverride 1 "yes";
  };

  users = {
    users = {
      root = {
        password = "hunter2";
      };
    };
    mutableUsers = false;
  };

  security.sudo.enable = true;

  i18n.consoleKeyMap = "${pkgs.local-packages.kbd}/share/keymaps/i386/qwerty/custom.map.gz";

  services.davfs2.enable = true;

  systemd.services.wait-for-dns = {
    enable = true;
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    bindsTo = [ "network-online.target" ];
    description = "Wait until DNS is available.";
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.stdenv.shell} -c 'until ${pkgs.bind.host}/bin/host cloud.maher.fyi; do sleep 1; done'";
    };
    partOf = [ "start-slideshow.service" ];
  };

  systemd.mounts = [
    {
      wantedBy = [ "remote-fs.target" ];
      after = [ "wait-for-dns.service" "network-online.target" ];
      bindsTo = [ "network-online.target" ];
      requires = [ "wait-for-dns.service" ];
      enable = true;
      what = "https://cloud.maher.fyi/remote.php/webdav/";
      where = picturesMountDir;
      type = "davfs";
      options = "_netdev";
      partOf = ["start-slideshow.service" ];
      mountConfig.TimeoutSec = 15;
    }
  ];

  environment.etc."davfs2/davfs2.conf" = {
    enable = true;
    # This file is not tracked here but it must be 0600 and owned by
    # root.  Certain special characters will cause it to fail, for
    #  example "\".
    # $ echo 'https://cloud.maher.fyi/remote.php/webdav/ username password' > /etc/davfs2/secrets
    text = ''
      secrets /etc/davfs2/secrets
    '';
  };

  systemd.services.configure-framebuffer = {
    enable = true;
    wantedBy = [ "multi-user.target" ];
    description = "Set framebuffer color depth.";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = ''${pkgs.busybox}/bin/fbset -depth 24'';
    };
  };

  systemd.services.start-slideshow = {
    enable = true;
    wantedBy = [ "multi-user.target" ];
    after = [ "configure-framebuffer.service" "mnt-nextcloud.mount" ];
    bindsTo = [ "mnt-nextcloud.mount" ];
    requires = [ "configure-framebuffer.service" ];
    description = "Start FIM slideshow.";
    serviceConfig = {
      Type = "simple";
      RuntimeMaxSec= "1h";
      Restart = "always";
      TimeoutStartSec = "5m"; # webdav is slow
    };
    script = ''
      ${pkgs.fim}/bin/fim \
        --autozoom \
        --random \
        --quiet \
        --recursive ${picturesMountDir} \
        --execute-commands 'while (1) { display; sleep 30; next; }'
    '';
  };
}
