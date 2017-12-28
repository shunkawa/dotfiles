{ lib, pkgs, ... }:

with pkgs;

rec {
  emacs-git = callPackage ./emacs-git {};

  nautilus-python = callPackage ./nautilus-python {};

  nodePackages = callPackage ./node-packages { nodejs = nodejs-8_x; };

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

  riot = callPackage ./riot {};

  libopenraw = callPackage ./libopenraw {};

  pia-nm = callPackage ./pia-nm {};

  nixfmt = haskellPackages.callPackage ./nixfmt {};

  javaws-desktop-file = callPackage ./javaws-desktop-file {
    icedtea = pkgs.icedtea8_web;
  };

  nuke-room-from-synapse = callPackage ./nuke-room-from-synapse {};

  get-pia-port-forwarding-assignment = callPackage ./get-pia-port-forwarding-assignment {};

  react-devtools = callPackage ./react-devtools {};

  imapnotify = callPackage ./impanotify {};

  purs = callPackage ./purs {};

  get-hostname = callPackage ./get-hostname {};

  nextcloud-client = (pkgs.nextcloud-client.override ({
    withGnomeKeyring = true;
    libgnome_keyring = pkgs.gnome3.libgnome_keyring;
  }));
}
