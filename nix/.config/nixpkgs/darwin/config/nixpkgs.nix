{ config, lib, pkgs, ... }:

{
  nixpkgs = {
    config = {
      allowBroken = true;
      allowUnfree = true;
      overlays = [ (import ../../packages/overlay.nix) ];
      packageOverrides = pkgs: {
        iterm2 = with pkgs; stdenv.mkDerivation rec {
          name = "iterm2";
          version = "3.1.5";

          src = fetchzip {
            url = "https://iterm2.com/downloads/stable/iTerm2-${lib.replaceStrings ["."] ["_"] version}.zip";
            sha256 = "1f4kz967m539iaia6z9gxqh3wmm9wfgnhn02i517ss45yfv769v4";
          };

          dontBuild = true;

          installPhase = ''
            mkdir -p $out/Applications/iTerm2.app
            cp -r Contents $out/Applications/iTerm2.app
          '';
        };

        syncthing = with pkgs; stdenv.mkDerivation rec {
          name = "syncthing";
          version = "0.14.42";

          src = fetchurl {
            url = "https://github.com/syncthing/syncthing/releases/download/v${version}/syncthing-macosx-amd64-v${version}.tar.gz";
            sha256 = "03b1w95f8rh8yk4dafcsic8kh48h4v5xsys4qvm30cj9apzyrirl";
          };

          buildInputs = [ gnutar ];

          dontBuild = true;

          installPhase = ''
            mkdir -p "$out/tmp";
            tar xf ${src} -C "$out/tmp" --strip-components 1
            mkdir -p "$out/bin";
            mv "$out/tmp/syncthing" "$out/bin"
            rm -rf "$out/tmp"
          '';
        };
      };
    };
  };
}
