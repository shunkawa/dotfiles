
{ stdenv, zlib }:

stdenv.mkDerivation rec {
  name = "sfnt2woff-" + version;
  version = "latest";

  src = fetchGit {
    url = "ssh://git@github.com/eqyiel/sfnt2woff.git";
    rev = "1898e24afc18bb63b11698095d8a45169df9496e";
  };

  installPhase = ''
    install -D -t $out/bin sfnt2woff
  '';

  buildInputs = [ zlib ];
}
