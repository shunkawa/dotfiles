{ stdenv, fetchFromGitHub }:
let
  versions = builtins.fromJSON (builtins.readFile ./versions.json);
in
stdenv.mkDerivation rec {
  name = "node-build";
  version = builtins.substring 0 7 versions.node-build.rev;

  src = fetchFromGitHub {
    owner = "nodenv";
    repo = "node-build";
    inherit (versions.node-build) rev sha256;
  };

  buildPhase = ''
    PREFIX=$out ./install.sh

    # This folder is created by the script, but is empty.
    rm -rf $out/etc
  '';
}
