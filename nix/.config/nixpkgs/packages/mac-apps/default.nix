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

  Anki = pkgs.anki;

  Chrome = (installApplication rec {
    name = "Chrome";
    # Chromium version numbers consist of 4 parts: MAJOR.MINOR.BUILD.PATCH.
    # https://www.chromium.org/developers/version-numbers
    version = "86.0.4240.80";
    sourceRoot = "Google Chrome.app";
    src = pkgs.fetchurl {
      # > Google does not offer older Versions of Chrome, in the name of Security.
      # https://superuser.com/questions/1381356/how-can-i-download-an-old-version-of-google-chrome
      #
      # nix-prefetch-url https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.Mg
      #
      # To verify that the version is correct:
      # python -c 'import fileinput; import plistlib; print(plistlib.loads(bytes("".join(fileinput.input()), "utf-8"))["CFBundleShortVersionString"]);' < "$(nix-build '<nixpkgs>' -A local-packages.mac-apps.Chrome --no-out-link)/Applications/Chrome.app/Contents/Info.plist"
      url = "https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg";
      sha256 = "0fwqac7pgjsvi0pdsh1k66krhgv0wrqg317fgaf1s06rdz8fl7d2";
    };
    description = "Google Chrome is a cross-platform web browser developed by Google.";
    homepage = https://www.google.com/chrome/;
  });

  Chromium = (installApplication rec {
    name = "Chromium";
    # Chromium version numbers consist of 4 parts: MAJOR.MINOR.BUILD.PATCH.
    # https://www.chromium.org/developers/version-numbers
    version = "86.0.4212.0";
    sourceRoot = "chrome-mac/${name}.app";
    src = pkgs.fetchurl {
      # How to update:
      # 1. Go to https://chromium.googlesource.com/chromium/src.git
      # 2. Look for `Cr-Commit-Position`, for example
      #    `refs/heads/master@{#791299}`:
      #    https://chromium.googlesource.com/chromium/src.git/+/c0803eb7aa7b711f90161a8f0bea90d859606009
      # 3. Get the version number https://chromium.googlesource.com/chromium/src.git/+/c0803eb7aa7b711f90161a8f0bea90d859606009/chrome/VERSION
      # 4. nix-prefetch-url "https://commondatastorage.googleapis.com/chromium-browser-snapshots/Mac/791299/chrome-mac.zip"
      url = "https://commondatastorage.googleapis.com/chromium-browser-snapshots/Mac/791299/chrome-mac.zip";
      sha256 = "0grscsi4rrjm5n4byrddn9xh1j664k662bb6jlgwf0wywmn7y7q8";
    };
    description = "Chromium is an open-source browser project that aims to build a safer, faster, and more stable way for all Internet users to experience the web";
    homepage = https://www.chromium.org/Home;
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

  Firefox = installApplication rec {
    name = "Firefox";
    # Check the release notes for the latest stable release:
    # https://www.mozilla.org/en-US/firefox/releases/
    version = "81.0.2";
    sourceRoot = "Firefox.app";
    src = pkgs.fetchurl {
      # Note that this filename has a space in it, so you have to provide the
      # --name argument to avoid an error:
      #
      # > error: The path name 'Firefox%2078.0.2.dmg' is invalid: the '%'
      # > character is invalid. Path names are alphanumeric and can include the
      # > symbols +-._?= and must not begin with a period. Note: If
      # > 'Firefox%2078.0.2.dmg' is a source file and you cannot rename it on
      # > disk, builtins.path { name = ... } can be used to give it an
      # > alternative name.
      #
      # (export VERSION="81.0.2"; nix-prefetch-url "https://ftp.mozilla.org/pub/firefox/releases/${VERSION}/mac/en-US/Firefox%20${VERSION}.dmg" --name "Firefox-${VERSION}.dmg")
      name = "Firefox-${version}.dmg";
      url = "https://ftp.mozilla.org/pub/firefox/releases/${version}/mac/en-US/Firefox%20${version}.dmg";
      sha256 = "1khzsnrk13z2lrwqd1vc6jm3qg7vmrgy996ss61ybfb6prjjj55s";
    };
    description = "The Firefox web browser";
    homepage = https://www.mozilla.org/en-US/firefox/;
  };

  GIMP = (installApplication rec {
    name = "GIMP";
    major = "2.10";
    minor = "14";
    version = "${major}.${minor}";
    sourceRoot = "Gimp-${major}.app";
    src = pkgs.fetchurl {
      url = "https://download.gimp.org/mirror/pub/gimp/v${major}/osx/gimp-${version}-x86_64-1.dmg";
      sha256 = "0lkyz7pwy8j366cp4cfs3cm23pzdygplnwjc2dn4z0wlz22lsraj";
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

  # iTerm2 = pkgs.iterm2;

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
