{ pkgs }:
let
  # This is a rip off from jwiegley's dotfiles:
  # https://github.com/jwiegley/nix-config/blob/5b8e287dc7157e8f9a55ff71f0a2822fea485b55/overlays/30-apps.nix#L3-L23
  installApplication =
    { name
    , appname ? name
    , version
    , src
    , description
    , homepage
    , postInstall ? ""
    , sourceRoot ? "."
    , ...
    }: with pkgs.super; stdenv.mkDerivation {
      name = "${name}-${version}";
      version = "${version}";
      src = src;
      buildInputs = with pkgs; [ undmg unzip ];
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
in
{
  Alfred = (installApplication rec {
    name = "Alfred";
    version = "4.0.8_1135";
    sourceRoot = "Alfred 4.app";
    src = pkgs.fetchurl {
      url = "https://cachefly.alfredapp.com/${name}_${version}.tar.gz";
      sha256 = "1i5bz7vb5dqvh8mps9mnryjx6hgg1kgdljgawqf14rrxklw8h0v3";
    };
    description = "Alfred is an award-winning app for macOS which boosts your efficiency with hotkeys, keywords, text expansion and more. Search your Mac and the web, and be more productive with custom actions to control your Mac.";
    homepage = https://www.alfredapp.com/;
  });

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

  Docker = installApplication rec {
    name = "Docker";
    version = "2.2.0.3";
    sourceRoot = "${name}.app";
    src = pkgs.fetchurl {
      # WARNING:
      # Docker doesn't publish a permalink for the latest build.  That means
      # that if you fetch this again using nix-prefetch-url, you will have to
      # install a different version. 😢 Best thing you can do is look on the
      # "release notes" page and get a "permalink" to an older version, which is
      # hostile-ly obfuscated by the "build" number or something.
      url = https://download.docker.com/mac/stable/42716/Docker.dmg;
      sha256 = "06snsqcw1ggb9s7s6i546na7kb6h45fxr7g77l7jj4bqv44yg4jq";
    };
    description = ''
      Docker Desktop for Mac is an easy-to-install desktop app for building,
      debugging, and testing Dockerized apps on a Mac.
    '';
    homepage = https://docs.docker.com/docker-for-mac/release-notes/;
  };

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

  iTerm2 = pkgs.iterm2;

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
}
