{ lib, pkgs, ... }:

with pkgs;

rec {
  inherit (import (callPackage ./hie-nix {})) stack2nix hies hie80 hie82;

  emacs-git = callPackage ./emacs-git {};

  emacs-with-packages = callPackage ./emacs-with-packages {};

  nautilus-python = callPackage ./nautilus-python {};

  indicator-kdeconnect = callPackage ./indicator-kdeconnect { inherit nautilus-python; };

  nodePackages = callPackage ./node-packages { nodejs = nodejs-10_x; };

  scss-lint = callPackage ./scss-lint {};

  rsvp-fyi = callPackage ./rsvp.fyi {
    grunt = nodePackages.grunt-cli;
    nodejs = nodejs-8_x;
    scss-lint = scss-lint;
  };

  openjfx = callPackage ./openjfx {};

  cryptomator = callPackage ./cryptomator {
    javafx = openjfx;
  };

  sfnt2woff = callPackage ./sfnt2woff {};

  sfnt2woff-zopfli = callPackage ./sfnt2woff-zopfli {};

  # Temporarily use this old bundler for generating fontcustom expressions.
  # Usage:
  # BUNDLER="$(nix-build '<nixpkgs>' -A local-packages.bundler)/bin/bundler" ./generate.sh
  # https://github.com/NixOS/nixpkgs/issues/36880#issuecomment-373197943
  bundler = pkgs.bundler.overrideAttrs (old: {
    name = "bundler-1.14.6";
    src = pkgs.fetchurl {
      url = "https://rubygems.org/gems/bundler-1.14.6.gem";
      sha256 = "0h3x2csvlz99v2ryj1w72vn6kixf7rl35lhdryvh7s49brnj0cgl";
    };
  });

  fontcustom = callPackage ./fontcustom {
    inherit sfnt2woff-zopfli;
    # Fontforge in unstable segfaults when using python script.
    fontforge = pkgs.fontforge.overrideAttrs (attrs: {
      name = "fontforge";
      version = null;
      src = pkgs.fetchFromGitHub {
        owner = "fontforge";
        repo = "fontforge";
        rev = "e688b8c4dc634dcc128709f84b98f2407294f3fb";
        sha256 = "1fsq7af9gx3bdfixd29ssx0jb1wnsild1pivjdrhkig74ikzxz8r";
      };
    });
  };

  browserpass = callPackage ./browserpass { gnupg = pkgs.gnupg22; };

  riot = callPackage ./riot {
    # I have had trouble building this package with any nodejs version other
    # than the one it was cooked for by node2nix, so make sure to use the same
    # one.
    nodejs = pkgs.nodejs-10_x;
  };

  libopenraw = callPackage ./libopenraw {};

  pia-nm = callPackage ./pia-nm {};

  nixfmt = haskellPackages.callPackage ./nixfmt {};

  javaws-desktop-file = callPackage ./javaws-desktop-file {
    icedtea = pkgs.icedtea8_web;
  };

  nuke-room-from-synapse = callPackage ./nuke-room-from-synapse {};

  get-pia-port-forwarding-assignment = callPackage ./get-pia-port-forwarding-assignment {};

  react-devtools = (callPackage ./react-devtools { nodejs = nodejs-10_x; }).react-devtools;

  tern = (callPackage ./tern { nodejs = nodejs-10_x; }).tern;

  imapnotify = callPackage ./impanotify {};

  purs = callPackage ./purs {};

  get-hostname = callPackage ./get-hostname {};

  nextcloud-client = let
    libsForQt511WithOpenSsl1_1_x = (recurseIntoAttrs
      (lib.makeScope (pkgs.qt511.overrideScope (super: self: {
        qtbase = super.qtbase.override (attrs: {
          # qtbase propagates the openssl it receives, which is 1.0.x.
          # nextcloud-client now requires 1.1.x, make sure that qtbase is propagating
          # the correct version.
          openssl = openssl_1_1;
          # Avoid building with -plugin-sql-mysql because it pulls in
          # mariadb-connector-c, which uses openssl 1.0.x.
          mysql = null;
        });
      })).newScope mkLibsForQt5));
  in libsForQt511WithOpenSsl1_1_x.callPackage ./nextcloud-client {
    withGnomeKeyring = true;
    libgnome-keyring = gnome3.libgnome-keyring;
  };

  hnix = callPackage ./hnix {};

  open = callPackage ./open {};

  pass-show-first-line = callPackage ./pass-show-first-line {};

  hiptext = callPackage ./hiptext {
    # TODO: for some reason this derivation can't be overridden normally
    libav = (callPackage <nixpkgs/pkgs/development/libraries/libav/default.nix> {
      vaapiSupport = false; # This doesn't build on Darwin.
    }).libav_11;
  };

  # Use patched mozc that starts in Hiragana mode rather than direct input.
  ibus-engines.mozc = pkgs.ibus-engines.mozc.overrideAttrs (attrs: {
    # nix-prefetch-git git@github.com:eqyiel/mozc.git --rev HEAD
    src = pkgs.fetchFromGitHub {
      owner = "eqyiel";
      repo = "mozc";
      rev = "19bef07c53793c0037ca441b5feb5d54334e7c1a";
      sha256 = "04qfbzrlgnk9f27nn0bz0xklp8mqpi00wazgl5kx4wcf4lbfirzf";
    };
  });

  nixpkgs = {
    stable = (import (pkgs.callPackage ({ stdenv }: stdenv.mkDerivation {
      name = "nixpkgs";

      src = builtins.fetchTarball {
        url = https://github.com/NixOS/nixpkgs-channels/archive/91b286c8935b8c5df4a99302715200d3bd561977.tar.gz;
        sha256 = "1c4a31s1i95cbl18309im5kmswmkg91sdv5nin6kib2j80gixgd3";
      };
      # src = fetchGit {
      #   url = ../../../.nix-defexpr/nixpkgs;
      #   rev = "91b286c8935b8c5df4a99302715200d3bd561977";
      # };

      dontBuild = true;
      preferLocalBuild = true;

      installPhase = ''
        cp -a . $out
      '';
    }) {}) {});
    ayanami = (import (pkgs.callPackage ../nixos/config/ayanami/lib/nixpkgs.nix {}) {});
    darwin = (import (pkgs.callPackage ../darwin/lib/nixpkgs.nix {}) {});
    home = (import (pkgs.callPackage ../home/lib/nixpkgs.nix {}) {});
    hoshijiro = (import (pkgs.callPackage ../nixos/config/hoshijiro/lib/nixpkgs.nix {}) {});
    tomoyo = (import (pkgs.callPackage ../nixops/realms/tomoyo.maher.fyi/lib/nixpkgs.nix {}) {});
  };

  subtitles-rs = callPackage ./subtitles-rs {};

  aligner = callPackage ./aligner {};

  google-java-format = callPackage ./google-java-format {};

  dualsub = callPackage ./dualsub {};

  gitlab-discord-bot = (callPackage ./gitlab-discord-bot {});
}
