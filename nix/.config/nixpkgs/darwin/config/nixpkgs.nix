{ config, lib, pkgs, ... }:

{
  nixpkgs = {
    overlays = [ (import ../../packages/overlay.nix) ];
    config = {
      allowBroken = false;
      allowUnfree = true;
      packageOverrides = pkgs: {
        iterm2 = with pkgs; stdenv.mkDerivation rec {
          name = "iterm2";
          version = "3.3.0beta13";

          src = fetchzip {
            url = "https://iterm2.com/downloads/beta/iTerm2-${lib.replaceStrings ["."] ["_"] version}.zip";
            sha256 = "113b9hybz5k6k5zx4d988dm3yr31cp1xak4l2i0rywdphpaixqpg";
          };

          dontBuild = true;

          installPhase = ''
            mkdir -p $out/Applications/iTerm2.app
            cp -r Contents $out/Applications/iTerm2.app
          '';
        };

        syncthing = with pkgs; stdenv.mkDerivation rec {
          name = "syncthing";
          version = "1.1.4";

          src = fetchurl {
            url = "https://github.com/syncthing/syncthing/releases/download/v${version}/syncthing-macos-amd64-v${version}.tar.gz";
            sha256 = "0gi8rcz63yvxcpa5f47a4wygsh3s1613097hwn0vj8whxlanq64x";
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

  # supposedly this is the default, but it's not.
  nix.package = pkgs.nix;

  nix.trustedBinaryCaches = [ "https://cache.nixos.org" ];
}
