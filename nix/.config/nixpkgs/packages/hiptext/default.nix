{ stdenv
, autoreconfHook
, fetchFromGitHub
, libav
, freetype
, gflags
, glog
, libjpeg
, libpng
, pkgconfig
, ragel
}:

stdenv.mkDerivation rec {
  name = "hiptext-" + version;
  version = "HEAD";

  # nix-prefetch-git git@github.com:jart/hiptext.git --rev HEAD
  src = fetchFromGitHub {
    owner = "jart";
    repo = "hiptext";
    rev = "da18b54c614beb74b7cb8671ea501caae2f8e85f";
    sha256 = "0m8vv103nj7pbz5lzzcgjdkasgygjv52zaxrh63yvd85c6pl339v";
  };

  buildInputs = [
    autoreconfHook
    libav
    freetype
    gflags
    glog
    libjpeg
    libpng
    pkgconfig
    ragel
  ];
}
