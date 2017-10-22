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
          date = "2017-10-21"; channel = "nightly";
        });
      in {
        rustPlatform = super.makeRustPlatform {
          rustc = rustChannel.rust;
          inherit (rustChannel) cargo;
        };

        rust = {
          inherit (rustChannel) cargo;
          rustc = rustChannel.rust;
        };
      })
    ];
  })) rustPlatform;

in with rustPlatform; buildRustPackage rec {
  name = "purs-${version}";
  version = "git";

  rustRegistry = (import <nixpkgs> {}).rustRegistry.overrideAttrs (attrs: {
    name = "rustRegistry-2017-10-22";

    src = fetchFromGitHub {
      owner = "rust-lang";
      repo = "crates.io-index";
      rev = "a1291863947253db65f19054f8a579dde287b7a9";
      sha256 = "095n803aqhpigaqyicrhi83rgl2k4n4cpddhrdymi7qlfy4h50i8";
    };
  });

  src = fetchFromGitHub {
    owner = "xcambar";
    repo = "purs";
    rev = "eed4e9c1fb4e08a6baaf52c10edee257c75fb8da";
    sha256 = "1ilclfj49fcp44d1wfabw9wmapr81knxa9c0s2jkgxw2cq4wqxqn";
  };

  buildInputs = [ openssl ];

  depsSha256 = "0mn87w2jzwla94lsvvs6yjfsd99942nrj96cvxxx42zyx4xn96i1";
}
