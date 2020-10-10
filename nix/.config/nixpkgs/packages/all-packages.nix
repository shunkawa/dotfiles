{ lib, pkgs, ... }:

with pkgs;

rec {
  inherit (import (callPackage ./hie-nix { })) stack2nix hies hie80 hie82;

  emacs-git = callPackage ./emacs-git { };

  emacs-with-packages = callPackage ./emacs-with-packages { emacs = emacs-git; };

  nautilus-python = callPackage ./nautilus-python { };

  indicator-kdeconnect = callPackage ./indicator-kdeconnect { inherit nautilus-python; };

  nodePackages = callPackage ./node-packages { nodejs = nodejs-10_x; };

  scss-lint = callPackage ./scss-lint { };

  rsvp-fyi = callPackage ./rsvp.fyi {
    grunt = nodePackages.grunt-cli;
    nodejs = nodejs-8_x;
    scss-lint = scss-lint;
  };

  openjfx = callPackage ./openjfx { };

  cryptomator = callPackage ./cryptomator {
    javafx = openjfx;
  };

  sfnt2woff = callPackage ./sfnt2woff { };

  sfnt2woff-zopfli = callPackage ./sfnt2woff-zopfli { };

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

  libopenraw = callPackage ./libopenraw { };

  pia-nm = callPackage ./pia-nm { };

  nixfmt = haskellPackages.callPackage ./nixfmt { };

  javaws-desktop-file = callPackage ./javaws-desktop-file {
    icedtea = pkgs.icedtea8_web;
  };

  nuke-room-from-synapse = callPackage ./nuke-room-from-synapse { };

  get-pia-port-forwarding-assignment = callPackage ./get-pia-port-forwarding-assignment { };

  react-devtools = (callPackage ./react-devtools { nodejs = nodejs-10_x; }).react-devtools;

  tern = (callPackage ./tern { nodejs = nodejs-10_x; }).tern;

  imapnotify = callPackage ./impanotify { };

  purs = callPackage ./purs { };

  get-hostname = callPackage ./get-hostname { };

  nextcloud-client =
    let
      libsForQt511WithOpenSsl1_1_x = (
        recurseIntoAttrs (
          lib.makeScope
            (pkgs.qt511.overrideScope' (self: super: {
              qtbase = super.qtbase.override (attrs: {
                # qtbase propagates the openssl it receives, which is 1.0.x.
                # nextcloud-client now requires 1.1.x, make sure that qtbase is propagating
                # the correct version.
                openssl = openssl_1_1;
                # Avoid building with -plugin-sql-mysql because it pulls in
                # mariadb-connector-c, which uses openssl 1.0.x.
                mysql = null;
              });
            })).newScope
            mkLibsForQt5
        )
      );
    in
    libsForQt511WithOpenSsl1_1_x.callPackage ./nextcloud-client {
      withGnomeKeyring = true;
      libgnome-keyring = gnome3.libgnome-keyring;
    };

  hnix = callPackage ./hnix { };

  open = callPackage ./open { };

  pass-show-first-line = callPackage ./pass-show-first-line { };

  hiptext = callPackage ./hiptext {
    glog =
      callPackage
        ({ stdenv, lib, fetchFromGitHub, fetchpatch, autoreconfHook, perl }:
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
          }
        )
        { };
    # TODO: for some reason this derivation can't be overridden normally
    libav = (callPackage <nixpkgs/pkgs/development/libraries/libav/default.nix> {
      vaapiSupport = false; # This doesn't build on Darwin.
    }
    ).libav_11;
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

  subtitles-rs = callPackage ./subtitles-rs { };

  aligner = callPackage ./aligner { };

  google-java-format = callPackage ./google-java-format { };

  dualsub = callPackage ./dualsub { };

  gitlab-discord-bot = (callPackage ./gitlab-discord-bot { });

  mu = pkgs.mu;

  omnisharp-roslyn = callPackage ./omnisharp-roslyn { };

  docker-convenience-scripts = callPackage ./docker-convenience-scripts { };

  pass = pkgs.pass.overrideAttrs (attrs: { doInstallCheck = false; });

  node-build = callPackage ./nodenv/node-build.nix { };

  nodenv = callPackage ./nodenv { };

  goose = callPackage ./goose { };

  git-archive-all = callPackage ./git-archive-all { };

  custom-kbd =
    callPackage
      ({ stdenv, kbd }: stdenv.mkDerivation {
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
      })
      { };

  zsh-packages = recurseIntoAttrs (callPackage ./zsh-packages { });

  tmux-packages = recurseIntoAttrs (callPackage ./tmux-packages { });

  mac-apps = recurseIntoAttrs (callPackage ./mac-apps { });

  curl-verbose = callPackage ./curl-verbose { };

  comma = callPackage ./comma { };

  pinentry-wrapper = callPackage ./pinentry-wrapper { };

  zynaddsubfx = (recurseIntoAttrs (callPackage ./zynaddsubfx { }));

  carla = qt5.callPackage ./carla {
    inherit (darwin.apple_sdk.frameworks) CoreAudioKit WebKit;
  };

  remark-lint-wrapper =
    import
      (builtins.fetchTarball https://github.com/eqyiel/remark-lint-wrapper/archive/v1.0.0.tar.gz)
      {
        inherit pkgs;
        inherit system;
      };

  eb = callPackage ./eb { };

  yomichan-import = callPackage ./yomichan-import {
    zero-epwing = callPackage ./yomichan-import/zero-epwing.nix {
      inherit eb;
      jansson = callPackage ./yomichan-import/jansson.nix { };
    };
    yomichan-import = callPackage ./yomichan-import/yomichan-import.nix {
      inherit (darwin.apple_sdk.frameworks) AppKit;
    };
  };

  nur =
    import (builtins.fetchTarball {
      # Get the revision by choosing a version from
      # https://github.com/nix-community/NUR/commits/master"
      url = "https://github.com/nix-community/NUR/archive/b9649a747e43c62f50829f87426c02ac0a7c5364.tar.gz";
      # Get the hash by running `nix-prefetch-url --unpack <url>` on the above url
      sha256 = "0fbrwk5bd8mirrkhhnlx8ln9d9lp8bw1lz4s8wxz61m3gh0g2qii";
    });

  qolibri = nixpkgs."nixpkgs-unstable-2020-08-23".libsForQt5.callPackage ./qolibri {
    inherit eb;
  };

  nixpkgs = recurseIntoAttrs {
    # nix-prefetch-url --unpack https://github.com/NixOS/nixpkgs-channels/archive/96745f0228359a71051a1d0bda4080e7ec134ade.tar.gz
    "darwin-20.03-eqyiel-qtwebengine-backport-2020-08-23" =
      import
        (builtins.fetchTarball {
          name = "darwin-20.03-eqyiel-qtwebengine-backport-2020-08-23";
          url = https://github.com/eqyiel/nixpkgs/archive/e5612ebe3fd90ea2af22d475f1037ba458c194f0.tar.gz;
          sha256 = "18bcs88b7wgn8j87xi54q0n3y8i1qf59j3i7sm6xvimbavrbcg96";
        })
        { };

    "nixpkgs-unstable-2020-08-23" =
      import
        (builtins.fetchTarball {
          name = "nixpkgs-unstable-2020-08-23";
          url = https://github.com/NixOS/nixpkgs-channels/archive/ddfa22167019726c015a5638e815d028031162e8.tar.gz;
          sha256 = "03sa3h00k4qiy511gjxvpw78wdph9bn8hvfsjjq49297vavxh0cv";
        })
        { };
  };
}
