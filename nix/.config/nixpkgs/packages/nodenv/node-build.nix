{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "node-build";
  version = "4.9.1";

  src = fetchFromGitHub {
    owner = "nodenv";
    repo = "node-build";
    rev = "v${version}";
    sha256 = "0ni7sqg318dlg21cp7alkp4dciaxm48cnrmvn9qx2yccxqzvcv53";
  };

  buildPhase = ''
    PREFIX=$out ./install.sh

    # This folder is created by the script, but is empty.
    rm -rf $out/etc
  '';
}
