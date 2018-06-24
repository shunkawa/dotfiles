{ stdenv, fetchgit }:

stdenv.mkDerivation {

  name = "matrix-appservice-irc-nixos";
  src = fetchgit {
    url = ../../../../../../../.nix-defexpr/matrix-appservice-irc-nixos;
    rev = "3ef06781a91202e7c0b24536788abe60ec3ae36";
    sha256 = "062b2ayfj26klwsfi2r6knlllx33rzl8gwjxic3gxdj05bn7jb1";
  };

  dontBuild = true;
  preferLocalBuild = true;

  installPhase = ''
    cp -a . $out
  '';
}
