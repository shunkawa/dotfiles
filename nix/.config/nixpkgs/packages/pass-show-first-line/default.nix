{ stdenv }:

stdenv.mkDerivation rec {
  name = "pass-show-first-line";

  unpackPhase = "true"; # nothing to unpack

  src = ./pass-show-first-line.sh;

  dontConfigure = true;

  dontBuild = true;

  installPhase = ''
    install -D -m755 $src $out/bin/pass-show-first-line
  '';
}
