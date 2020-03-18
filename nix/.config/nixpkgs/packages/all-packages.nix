{ lib, pkgs, ... }:

with pkgs;

let
  # This is a rip off from jwiegley's dotfiles:
  # https://github.com/jwiegley/nix-config/blob/5b8e287dc7157e8f9a55ff71f0a2822fea485b55/overlays/30-apps.nix#L3-L23
  installApplication = {
    name,
    appname ? name,
    version,
    src,
    description,
    homepage,
    postInstall ? "",
    sourceRoot ? ".",
    ...
  }: with super; stdenv.mkDerivation {
    name = "${name}-${version}";
    version = "${version}";
    src = src;
    buildInputs = [ undmg unzip ];
    sourceRoot = sourceRoot;
    phases = [ "unpackPhase" "installPhase" ];
    installPhase = ''
      mkdir -p "$out/Applications/${appname}.app"
      cp -pR * "$out/Applications/${appname}.app"
    '' + postInstall;
    meta = with stdenv.lib; {
      description = description;
      homepage = homepage;
      maintainers = with maintainers; [ eqyiel ];
      platforms = platforms.darwin;
    };
  };
in rec {
  inherit (import (callPackage ./hie-nix {})) stack2nix hies hie80 hie82;

  emacs-git = callPackage ./emacs-git {};

  emacs-with-packages = callPackage ./emacs-with-packages { emacs = emacs-git; };

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
      (lib.makeScope (pkgs.qt511.overrideScope' (self: super: {
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
    glog = callPackage ({ stdenv, lib, fetchFromGitHub, fetchpatch, autoreconfHook, perl }:
      stdenv.mkDerivation rec {
        pname = "glog";
        version = "0.4.0";

        src = fetchFromGitHub {
          owner = "google";
          repo = "glog";
          rev = "v${version}";
          sha256 = "1xd3maiipfbxmhc9rrblc5x52nxvkwxp14npg31y5njqvkvzax9b";
        };

        patches = lib.optionals stdenv.hostPlatform.isMusl [
          # TODO: Remove at next release that includes this commit.
          (fetchpatch {
            name = "glog-Fix-symbolize_unittest-for-musl-builds.patch";
            url = "https://github.com/google/glog/commit/834dd780bf1fe0704b8ed0350ca355a55f711a9f.patch";
            sha256 = "0k4lanxg85anyvjsj3mh93bcgds8gizpiamcy2zvs3yyfjl40awn";
          })
        ];

        nativeBuildInputs = [ autoreconfHook ];

        checkInputs = [ perl ];
        doCheck = false; # fails with "Mangled symbols (28 out of 380) found in demangle.dm"

        meta = with stdenv.lib; {
          homepage = https://github.com/google/glog;
          license = licenses.bsd3;
          description = "Library for application-level logging";
          platforms = platforms.unix;
        };
      }) {};
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
    last-known-good = (import (pkgs.callPackage ({ stdenv }: stdenv.mkDerivation {
      name = "nixpkgs";

      src = fetchGit {
        url = ../../../.nix-defexpr/nixpkgs;
        rev = "90441b4b47fc7280de6a5bd1a228017caaa0f97f";
      };

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

  mu = pkgs.mu;

  Anki = installApplication rec {
    name = "Anki";
    version = "2.1.21";
    sourceRoot = "${name}.app";
    src = pkgs.fetchurl {
      url = "https://github.com/ankitects/anki/releases/download/${version}/anki-${version}-mac.dmg";
      sha256 = "0cm9bb104wz0pd1mxfahi4s32hgn0wsac0i61fi12ipkwz84vq0z";
    };
    description = "Anki is a program which makes remembering things easy";
    homepage = https://apps.ankiweb.net;
  };

  Docker = installApplication rec {
    name = "Docker";
    version = "2.1.0.1";
    sourceRoot = "${name}.app";
    src = pkgs.fetchurl {
      # WARNING:
      # Docker doesn't publish a permalink for the latest build.
      # That means that if you fetch this again using nix-prefetch-url, you will
      # have to install a different version. 😢
      url = https://download.docker.com/mac/stable/Docker.dmg;
      sha256 = "06nhg3hddzn3l7yky36drypjkcvbbc2qbyazkjj0i0yq09knjf5n";
    };
    description = ''
      Docker Desktop for Mac is an easy-to-install desktop app for building,
      debugging, and testing Dockerized apps on a Mac.
    '';
    homepage = https://download.docker.com/mac/stable/Docker.dmg;
  };

  Spectacle = installApplication rec {
    name = "Spectacle";
    version = "1.2";
    sourceRoot = "${name}.app";
    src = pkgs.fetchurl {
      url = https://s3.amazonaws.com/spectacle/downloads/Spectacle+1.2.zip;
      sha256 = "037kayakprzvs27b50r260lwh2r9479f2pd221qmdv04nkrmnvbn";
    };
    description = "Window control with simple and customizable keyboard shortcuts";
    homepage = https://www.spectacleapp.com;
  };

  Karabiner-Elements = (installApplication rec {
    name = "Karabiner-Elements";
    version = "12.1.0";
    src = pkgs.fetchurl {
      url = https://pqrs.org/osx/karabiner/files/Karabiner-Elements-12.1.0.dmg;
      sha256 = "0bp69fp68bcljyq6jxkdf1mvpvzsb1davi3pddvbidy2zipdf7qf";
    };
    description = "A powerful and stable keyboard customizer for macOS.";
    homepage = https://pqrs.org/osx/karabiner;
  }).overrideAttrs (attrs: {
      buildInputs = attrs.buildInputs ++ (with pkgs; [ xar cpio ]);
      unpackPhase = ''
        undmg < $src
        xar -xf Karabiner-Elements.sparkle_guided.pkg
        gunzip < Installer.pkg/Payload | cpio -i
      '';
      installPhase = ''
        mkdir -p $out/Applications
        mkdir -p $out/Library
        ls -lha
        ls -lha $out
        cp -pR Applications/* $out/Applications
        cp -pR Library/* $out/Library
      '';
    });

  Sketch = (installApplication rec {
    name = "Sketch";
    version = "52.5";
    sourceRoot = "${name}.app";
    src = pkgs.fetchurl {
      url = https://download.sketchapp.com/sketch-52.5-67469.zip;
      sha256 = "0msggx6qghb53i04mnzcjlqqqzh9qjwxl9lkqb9bicdbb8lhh6d3";
    };
    description = "The website doesn't actually describe the product :(";
    homepage = https://www.sketchapp.com;
  });

  GIMP = (installApplication rec {
    name = "GIMP";
    major = "2.10";
    minor = "8";
    version = "${major}.${minor}";
    sourceRoot = "Gimp-${major}.app";
    src = pkgs.fetchurl {
      url = "https://download.gimp.org/mirror/pub/gimp/v${major}/osx/gimp-${version}-x86_64-2.dmg";
      sha256 = "04sggnbadvnd8sag4262varj2ivfvbqb1wyzcadnmb5lsnzjgrcf";
    };
    description = "GIMP is a cross-platform image editor";
    homepage = https://www.gimp.org;
  });

  ImageOptim = (installApplication rec {
    name = "ImageOptim";
    version = "1.8.8";
    sourceRoot = "${name}.app";
    src = pkgs.fetchurl {
      url = "https://imageoptim.com/ImageOptim${version}.tar.bz2";
      sha256 = "1qyc4fpx9bac3mi02gracv86c4xq1b6is3am79p1iw6bp19fd37l";
    };
    description = "ImageOptim makes images load faster";
    homepage = https://imageoptim.com;
  });

  SequelPro = (installApplication rec {
    name = "SequelPro";
    version = "1.1.2";
    sourceRoot = "Sequel Pro.app";
    src = pkgs.fetchurl {
      url = "https://github.com/sequelpro/sequelpro/releases/download/release-${version}/sequel-pro-${version}.dmg";
      sha256 = "1il7yc3f0yzxkra27bslnmka5ycxzx0q4m3xz2j9r7iyq5izsd3v";
    };
    description = "MySQL/MariaDB database management for macOS";
    homepage = https://sequelpro.com;
  });

  Contexts = (installApplication rec {
    name = "Contexts";
    version = "3.7.1";
    sourceRoot = "${name}.app";
    src = pkgs.fetchurl {
      url = "https://contexts.co/releases/${name}-${version}.dmg";
      sha256 = "11ws96nzq18mixcnjgcqlcal2s2qmv8kkd86aqapc0n31ik4lpny";
    };
    description = "Radically simpler & faster window switcher for macOS";
    homepage = https://contexts.co/;
  });

  omnisharp-roslyn = callPackage ./omnisharp-roslyn {};

  docker-convenience-scripts = callPackage ./docker-convenience-scripts {};

  pass = pkgs.pass.overrideAttrs (attrs: { doInstallCheck = false; });

  node-build = callPackage ./nodenv/node-build.nix {};

  nodenv = callPackage ./nodenv {};

  goose = callPackage ./goose {};

  git-archive-all = callPackage ./git-archive-all {};
}
