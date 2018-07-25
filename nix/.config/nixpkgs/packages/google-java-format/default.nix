{ stdenv, fetchurl, jre, makeWrapper }:

stdenv.mkDerivation rec {
  version = "1.5";
  name = "google-java-format-${version}";

  jar = fetchurl {
    url = "https://github.com/google/google-java-format/releases/download/google-java-format-1.5/google-java-format-${version}-all-deps.jar";
    sha256 = "116izahj0i0fh3izd37czi80ill165c9l3nds073y5saafvrp0vv";
  };

  buildInputs = [ makeWrapper ];

  phases = "installPhase";

  installPhase = ''
    mkdir -p $out/share/java
    ln -s $jar $out/share/java/google-java-format-${version}-all-deps.jar
    makeWrapper ${jre}/bin/java $out/bin/google-java-format --add-flags "-jar $out/share/java/google-java-format-${version}-all-deps.jar"
  '';

  meta = {
    description = "Reformats Java source code to comply with Google Java Style";
    homepage = https://github.com/google/google-java-format;
    license = stdenv.lib.licenses.asl20;
  };
}
