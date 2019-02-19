{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation {
  name = "docker-convenience-scripts";

  src = fetchFromGitHub {
    owner = "gdiepen";
    repo = "docker-convenience-scripts";
    rev = "ba2158103068c8f9d3260a839cbea19eccea272d";
    sha256 = "11ddgi4gcdc9r2sci2cwqw82vd6z6yzhccz01bg1d5hd98kky90w";
  };

  dontBuild = true;

  dontConfigure = true;

  installPhase = ''
    mkdir -p $out/bin
    cp $src/*.sh $out/bin
    chmod +x $out/bin/*.sh
  '';
}
