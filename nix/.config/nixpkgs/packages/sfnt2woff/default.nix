{ stdenv, fetchgit, zlib }:

stdenv.mkDerivation rec {
  name = "sfnt2woff-" + version;
  version = "latest";

  src = fetchgit {
    url = "git@github.com:eqyiel/sfnt2woff.git";
    sha256 = "02ymdcpblhp2h83rdpmkl8zrpymn2y6w9nz1a2qqa9p3xlzr052p";
    rev = "1898e24afc18bb63b11698095d8a45169df9496e";
  };

  installPhase = ''
    install -D -t $out/bin sfnt2woff
  '';

  buildInputs = [ zlib ];
}
