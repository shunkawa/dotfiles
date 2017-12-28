{ stdenv, fetchFromGitHub, openssl, cmake, rustPlatform, zlib, libiconv,
  darwin, curl, pkgconfig }:

with rustPlatform; buildRustPackage rec {
  name = "purs-${version}";
  version = "git";

  preferLocalBuild = true;

  src = fetchFromGitHub {
    owner = "xcambar";
    repo = "purs";
    rev = "eed4e9c1fb4e08a6baaf52c10edee257c75fb8da";
    sha256 = "1ilclfj49fcp44d1wfabw9wmapr81knxa9c0s2jkgxw2cq4wqxqn";
  };

  buildInputs = [
    openssl cmake zlib libiconv curl
  ] ++ stdenv.lib.optional stdenv.isDarwin darwin.apple_sdk.frameworks.Security
    ++ stdenv.lib.optional stdenv.isLinux pkgconfig;

  cargoSha256 = "1sz39cf15kaiazgxv3ggl4agy01j6ql5fz98arq42a2yfag2jyai";
}
