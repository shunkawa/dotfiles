{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "hie-nix-${version}";
  version = "2018-02-11";

  src = fetchFromGitHub {
    owner = "domenkozar";
    repo = "hie-nix";
    rev = "79584143206f3bb1bbf5cc49abd8297a2a1712ad";
    sha256 = "0z1c59shwcg8d96v6dxb3xnc09mkn1c4ky1i4rf6hsx51z8whn6l";
  };

  dontBuild = true;
  preferLocalBuild = true;

  installPhase = ''
    cp -a . $out
  '';
}
