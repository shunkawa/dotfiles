{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "node-build";
  version = "4.8.0";

  src = fetchFromGitHub {
    owner = "nodenv";
    repo = "node-build";
    rev = "v${version}";
    sha256 = "01nvlpk9acwn1x2fgyvfd37yd4aa3krv3r3vsvz8n5hgrjpmmzsi";
  };

  buildPhase = ''
    PREFIX=$out ./install.sh

    # This folder is created by the script, but is empty.
    rm -rf $out/etc
  '';
}
