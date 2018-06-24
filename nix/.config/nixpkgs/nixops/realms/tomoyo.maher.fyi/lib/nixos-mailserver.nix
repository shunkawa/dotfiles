{ stdenv, fetchgit }:

stdenv.mkDerivation {

  name = "nixos-mailserver";
  src = fetchgit {
    url = ../../../../../../../.nix-defexpr/nixos-mailserver;
    rev = "ffc67fef469c0ec81c83b7d2681a8b2ca0c58849";
    sha256 = "1if8pshc4z5zn59zcnnjh55fk4gym0pjzlyxpc0x95l3vp916s40";
  };

  dontBuild = true;
  preferLocalBuild = true;

  installPhase = ''
    cp -a . $out
  '';
}
