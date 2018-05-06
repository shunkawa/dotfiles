{ stdenv, fetchgit }:

stdenv.mkDerivation rec {
  name = "hie-nix-${version}";
  version = "2018-02-11";

  src = fetchgit {
    inherit ((builtins.fromJSON (builtins.readFile ./packages.json)).hie-nix)
      url rev sha256;
  };

  dontBuild = true;
  preferLocalBuild = true;

  installPhase = ''
    cp -a . $out
  '';
}
