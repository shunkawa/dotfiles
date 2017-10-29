{ stdenv, fetchFromGitHub, openssl }:

let

  rustOverlay = fetchFromGitHub {
    owner = "mozilla";
    repo = "nixpkgs-mozilla";
    rev = "6179dd876578ca2931f864627598ede16ba6cdef";
    sha256 = "1lim10a674621zayz90nhwiynlakxry8fyz1x209g9bdm38zy3av";
  };

  inherit ((import <nixpkgs> {
    overlays = [
      (import (builtins.toPath "${rustOverlay}/rust-overlay.nix"))
      (self: super: let
        rustChannel = (super.rustChannelOf {
          date = "2017-10-29"; channel = "nightly";
        });
      in{
        rustPlatform = super.makeRustPlatform {
          # rustc = rustChannel.rust;
          inherit (rustChannel) rustc cargo;
        };

        rust = {
          inherit (rustChannel) rustc cargo;
          # rustc = rustChannel.rust;
        };

        rustRegistry = (import <nixpkgs> {}).rustRegistry.overrideAttrs (attrs: {
          name = "rustRegistry-2017-10-29";

          preferLocalBuild = true;

          src = fetchFromGitHub {
            owner = "rust-lang";
            repo = "crates.io-index";
            rev = "e8b77329e16edf2634b130eb8e82f7ecd1952c57";
            sha256 = "0ibjr8yqqldrhmaccgd8g9q3na0mkfflqvf02pbwk3d3kkafkckn";
          };
        });
      })
    ];
  })) rustPlatform;

in with rustPlatform; buildRustPackage rec {
  name = "purs-${version}";
  version = "git";

  preferLocalBuild = true;

  src = fetchFromGitHub {
    owner = "xcambar";
    repo = "purs";
    rev = "eed4e9c1fb4e08a6baaf52c10edee257c75fb8da";
    sha256 = "1ilclfj49fcp44d1wfabw9wmapr81knxa9c0s2jkgxw2cq4wqxqn";
  };

  buildInputs = [ openssl ];

  cargoSha256 = "1sz39cf15kaiazgxv3ggl4agy01j6ql5fz98arq42a2yfag2jyai";
}
