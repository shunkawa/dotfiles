{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "nixpkgs";

  src = fetchFromGitHub {
    owner = "eqyiel";
    repo = "nixpkgs";
    rev = "a8c71037e041725d40fbf2f3047347b6833b1703";
    sha256 = "1z4cchcw7qgjhy0x6mnz7iqvpswc2nfjpdynxc54zpm66khfrjqw";
  };

  dontBuild = true;
  preferLocalBuild = true;

  installPhase = ''
    cp -a . $out
  '';
}
