{ lib, pkgs, ... }:

with pkgs;

rec {
  inherit (import (callPackage ./hie-nix {})) stack2nix hies hie80 hie82;

  emacs-git = callPackage ./emacs-git {};

  emacs-with-packages = callPackage ./emacs-with-packages {};

  nautilus-python = callPackage ./nautilus-python {};

  indicator-kdeconnect = callPackage ./indicator-kdeconnect { inherit nautilus-python; };

  nodePackages = callPackage ./node-packages { nodejs = nodejs-9_x; };

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

  fontcustom = callPackage ./fontcustom { inherit sfnt2woff; };

  browserpass = callPackage ./browserpass { gnupg = pkgs.gnupg22; };

  riot = callPackage ./riot {
    # I have had trouble building this package with any nodejs version other than the one it was
    # cooked for by node2nix, so make sure to use the same one.
    nodejs = pkgs.nodejs-6_x;
  };

  libopenraw = callPackage ./libopenraw {};

  pia-nm = callPackage ./pia-nm {};

  nixfmt = haskellPackages.callPackage ./nixfmt {};

  javaws-desktop-file = callPackage ./javaws-desktop-file {
    icedtea = pkgs.icedtea8_web;
  };

  nuke-room-from-synapse = callPackage ./nuke-room-from-synapse {};

  get-pia-port-forwarding-assignment = callPackage ./get-pia-port-forwarding-assignment {};

  react-devtools = (callPackage ./react-devtools { nodejs = nodejs-9_x; }).react-devtools;

  tern = (callPackage ./tern { nodejs = nodejs-9_x; }).tern;

  imapnotify = callPackage ./impanotify {};

  purs = callPackage ./purs {};

  get-hostname = callPackage ./get-hostname {};

  # Can't cook on unstable due to this:
  # https://github.com/nextcloud/desktop/issues/235
  # Override version from impala instead.
  nextcloud-client =
    let impala = (import (pkgs.callPackage ({ stdenv, fetchFromGitHub }:
      stdenv.mkDerivation rec {
        name = "nixpkgs-${version}";
        version = "2018-06-25";

        src = fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "91b286c8935b8c5df4a99302715200d3bd561977";
          sha256 = "1c4a31s1i95cbl18309im5kmswmkg91sdv5nin6kib2j80gixgd3";
        };

        dontBuild = true;
        preferLocalBuild = true;

        installPhase = ''
          cp -a . $out
        '';
      }) {}) {});
  in impala.nextcloud-client.override ({
    withGnomeKeyring = true;
    libgnome-keyring = pkgs.gnome3.libgnome-keyring;
  });

  hnix = callPackage ./hnix {};

  open = callPackage ./open {};

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
}
