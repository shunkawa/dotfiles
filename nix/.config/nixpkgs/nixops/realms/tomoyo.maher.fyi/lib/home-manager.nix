{ stdenv, fetchgit }:

stdenv.mkDerivation {

  name = "home-manager";
  src = fetchgit {
    url = ../../../../../../../.nix-defexpr/home-manager;
    rev = "5641ee3f942e700de35b28fc879b0d8a10a7a1fe";
    sha256 = "0bqzwczbr5c2y3ms7m7ly0as9zsnqwljq61ci2y2gbqzw3md1x2j";
  };

  dontBuild = true;
  preferLocalBuild = true;

  installPhase = ''
    cp -a . $out
  '';
}
