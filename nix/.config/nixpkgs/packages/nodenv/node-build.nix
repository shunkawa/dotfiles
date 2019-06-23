{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "node-build";
  version = "4.6.1";

  src = fetchFromGitHub {
    owner = "nodenv";
    repo = "node-build";
    rev = "v${version}";
    sha256 = "0hza05g841klbji6417m5xrql83jqm9n6wpskh6qrwha8y68kr5d";
  };

  buildPhase = ''
    PREFIX=$out ./install.sh

    # This folder is created by the script, but is empty.
    rm -rf $out/etc
  '';
}
