{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation {
  name = "nixos-mailserver";

  src = fetchFromGitHub {
    owner = "eqyiel";
    repo = "nixos-mailserver";
    rev = "b4f6d963650b959f12afb91221c78422b021fe7a";
    sha256 = "1m6dhwi3kl0hcfclyawqp8zgk3i428d4jm4f4fg225kfip45rg7x";
  };

  dontBuild = true;
  preferLocalBuild = true;

  installPhase = ''
    cp -a . $out
  '';
}
