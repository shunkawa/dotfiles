{ stdenv, fetchFromGitHub, zlib }:

stdenv.mkDerivation rec {
  name = "sfnt2woff-zopfli";

  src = fetchFromGitHub {
    owner = "bramstein";
    repo = "sfnt2woff-zopfli";
    sha256 = "11g2mphzy0ivw5gjfxij0z1i4ihdp16vs6z1183xclc915z14j5y";
    rev = "e50236af6bb19fa926d2fb4c6e5fbeb915c45391";
  };

  buildInputs = [ zlib ];

  installPhase = ''
    mkdir -p $out/bin
    install -D -t $out/bin sfnt2woff-zopfli
    ln -s $out/bin/sfnt2woff-zopfli $out/bin/sfnt2woff
  '';
}
