{ nixpkgsSrc }: { pkgs, lib, config, ... }:

let
  picturesMountDir = "/mnt/nextcloud";

  mkForce = lib.mkOverride 1; # higher priority than lib.mkForce, which is 50
in {
  imports = [ "${nixpkgsSrc}/nixos/modules/installer/cd-dvd/sd-image-aarch64.nix" ];

  # Remove dependency on crda from wpa_supplicant because a required python
  # extension doesn't cross compile https://github.com/NixOS/nixpkgs/issues/53320
  services.udev.packages = mkForce [];
  # Override defaults from installation-device.nix (imported by sd-image-aarch64.nix)
  documentation.enable = mkForce false;
  documentation.nixos.enable = mkForce false;
  services.nixosManual.showManual = mkForce false;
  # Disable because it pulls in meson, which fails to build for aarch64-linux
  services.udisks2.enable = mkForce false;
  security.polkit.enable = mkForce false;

  # installation-device.nix (which is imported by sd-image-aarch64.nix) disables
  # these units.
  systemd.services.sshd.wantedBy = mkForce [ "multi-user.target" ];
  systemd.services.wpa_supplicant.wantedBy = mkForce [ "multi-user.target" ];
  services.mingetty.autologinUser = mkForce null;

  nixpkgs = {
    crossSystem = lib.systems.elaborate lib.systems.examples.aarch64-multiplatform;
    localSystem = { system = "x86_64-linux"; };
    overlays = [
      (self: super: {
        davfs2 = super.davfs2.overrideAttrs (attrs: {
          configureFlags = super.stdenv.lib.optionals (super.stdenv.hostPlatform != super.stdenv.buildPlatform) [
            # AC_FUNC_MALLOC is broken on cross builds.
            "ac_cv_func_malloc_0_nonnull=yes"
            "ac_cv_func_realloc_0_nonnull=yes"
          ];
          nativeBuildInputs = super.stdenv.lib.optionals (super.stdenv.hostPlatform != super.stdenv.buildPlatform) [
            self.neon
          ];
        });
        neon = super.neon.overrideDerivation (attrs: { nativeBuildInputs = [ super.libxml2.dev ] ++ attrs.nativeBuildInputs; });
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
          emacs = (super.emacs.override ({ withX = false; withGTK3 = false; }));
          fim = (super.fim.override ({ x11Support = false; svgSupport = false; })).overrideAttrs (attrs: {
            nativeBuildInputs = super.stdenv.lib.optionals (super.stdenv.hostPlatform != super.stdenv.buildPlatform) [
              super.pkgsBuildTarget.flex
              super.pkgsBuildTarget.bison
            ];
            NIX_CFLAGS_COMPILE = "-pthread";
            configureFlags = [ "fim_cv_regex=no" "fim_cv_regex_broken=no" ];
          });
        };
      })
    ];
  };

  boot = rec {
    kernelPackages = pkgs.linuxPackagesFor ((pkgs.linux_rpi3.override ({
      # Use the kernel from 19.03 https://github.com/NixOS/nixpkgs/blob/34c7eb7545d155cc5b6f499b23a7cb1c96ab4d59/pkgs/os-specific/linux/kernel/linux-rpi.nix
      argsOverride = rec {
        modDirVersion = "4.14.70";
        tag = "1.20180919";
        version = "${modDirVersion}-${tag}";
        src = pkgs.fetchFromGitHub {
          owner = "raspberrypi";
          repo = "linux";
          rev = "raspberrypi-kernel_${tag}-1";
          sha256 = "1zjvzk6rhrn3ngc012gjq3v7lxn8hy89ljb7fqwld5g7py9lkf0b";
        };
        kernelPatches = [];
        defconfig = "bcmrpi3_defconfig";
      };
    })).overrideDerivation (attrs: {
      # Use the same postConfigure step as from 19.03 because it doesn't build
      # with this https://github.com/NixOS/nixpkgs/blame/master/pkgs/os-specific/linux/kernel/linux-rpi.nix#L40
      postConfigure = ''
        # The v7 defconfig has this set to '-v7' which screws up our modDirVersion.
        sed -i $buildRoot/.config -e 's/^CONFIG_LOCALVERSION=.*/CONFIG_LOCALVERSION=""/'
       '';
      # Same deal
      postFixup = with pkgs; ''
        dtbDir=${if stdenv.isAarch64 then "$out/dtbs/broadcom" else "$out/dtbs"}
        rm $dtbDir/bcm283*.dtb
        copyDTB() {
          cp -v "$dtbDir/$1" "$dtbDir/$2"
        }
      '' + lib.optionalString (lib.elem stdenv.hostPlatform.system ["armv6l-linux"]) ''
        copyDTB bcm2708-rpi-0-w.dtb bcm2835-rpi-zero.dtb
        copyDTB bcm2708-rpi-0-w.dtb bcm2835-rpi-zero-w.dtb
        copyDTB bcm2708-rpi-b.dtb bcm2835-rpi-a.dtb
        copyDTB bcm2708-rpi-b.dtb bcm2835-rpi-b.dtb
        copyDTB bcm2708-rpi-b.dtb bcm2835-rpi-b-rev2.dtb
        copyDTB bcm2708-rpi-b-plus.dtb bcm2835-rpi-a-plus.dtb
        copyDTB bcm2708-rpi-b-plus.dtb bcm2835-rpi-b-plus.dtb
        copyDTB bcm2708-rpi-b-plus.dtb bcm2835-rpi-zero.dtb
        copyDTB bcm2708-rpi-cm.dtb bcm2835-rpi-cm.dtb
      '' + lib.optionalString (lib.elem stdenv.hostPlatform.system ["armv7l-linux"]) ''
        copyDTB bcm2709-rpi-2-b.dtb bcm2836-rpi-2-b.dtb
      '' + lib.optionalString (lib.elem stdenv.hostPlatform.system ["armv7l-linux" "aarch64-linux"]) ''
        copyDTB bcm2710-rpi-3-b.dtb bcm2837-rpi-3-b.dtb
        copyDTB bcm2710-rpi-3-b-plus.dtb bcm2837-rpi-3-b-plus.dtb
        copyDTB bcm2710-rpi-cm3.dtb bcm2837-rpi-cm3.dtb
      '';
    }));
    consoleLogLevel = 0;
    kernelParams = [
      # suppress blinking cursor from drawing over framebuffer
      "vt.global_cursor_default=0"
      # print any kernel messages to tty3, not tty0 (prevent drawing over framebuffer)
      "console=tty3"
    ];
    supportedFilesystems = mkForce [ "vfat" "ntfs" ];
  };

  environment.systemPackages = with pkgs; [
    fd
    local-packages.emacs
    ripgrep
    tmux
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

  console.keyMap = "${pkgs.local-packages.kbd}/share/keymaps/i386/qwerty/custom.map.gz";

  services.davfs2.enable = true;

  systemd.services.wait-for-dns = {
    enable = true;
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    bindsTo = [ "network-online.target" ];
    description = "Wait until DNS is available.";
    serviceConfig = {
      Type = "simple";
      ExecStart = "/bin/sh -c 'until ${pkgs.bind.host}/bin/host cloud.maher.fyi; do sleep 1; done'";
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
      options = "_netdev,conf=/etc/davfs2/davfs2.conf";
      partOf = ["start-slideshow.service" ];
      mountConfig.TimeoutSec = 15;
    }
  ];

  environment.etc."davfs2/davfs2.conf" = mkForce {
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
      ${pkgs.local-packages.fim}/bin/fim \
        --autozoom \
        --random \
        --quiet \
        --recursive ${picturesMountDir} \
        --execute-commands 'while (1) { display; sleep 30; next; }'
    '';
  };

  installer.cloneConfig = false;
}
