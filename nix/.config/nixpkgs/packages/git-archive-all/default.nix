{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation {
  name = "git-archive-all";

  src = fetchFromGitHub {
    owner = "meitar";
    repo = "git-archive-all.sh";
    rev = "fc86194f00b678438f9210859597f6eead28e765";
    sha256 = "0qpq0f99cjhbbnvcdnasr9gixpvzdmp3qlvv5fcmnqj40pw58hj9";
  };

  dontBuild = true;

  dontConfigure = true;

  installPhase = ''
    mkdir -p $out/bin
    cp $src/git-archive-all.sh $out/bin/git-archive-all
    chmod +x $out/bin/git-archive-all
  '';
}
