{ stdenv }:

stdenv.mkDerivation rec {
  name = "open";

  unpackPhase = "true"; # nothing to unpack

  src = ./open.sh;

  dontConfigure = true;

  dontBuild = true;

  installPhase = ''
    install -D -m755 $src $out/bin/open
  '';
}
