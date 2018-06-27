{ stdenv }:

stdenv.mkDerivation {
  name = "matrix-appservice-irc-nixos";

  src = fetchGit {
    url = ../../../../../../.nix-defexpr/matrix-appservice-irc-nixos;
    rev = "c3ef06781a91202e7c0b24536788abe60ec3ae36";
  };

  dontBuild = true;
  preferLocalBuild = true;

  installPhase = ''
    cp -a . $out
  '';
}
