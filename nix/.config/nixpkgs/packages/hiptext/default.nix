{ stdenv
, autoreconfHook
, fetchFromGitHub
, freetype
, gflags
, glog
, libav
, libjpeg
, libpng
, makeWrapper
, pkgconfig
, ragel
}:

stdenv.mkDerivation rec {
  name = "hiptext";

  # nix-prefetch-git git@github.com:jart/hiptext.git --rev HEAD
  src = fetchFromGitHub {
    owner = "jart";
    repo = "hiptext";
    rev = "da18b54c614beb74b7cb8671ea501caae2f8e85f";
    sha256 = "0m8vv103nj7pbz5lzzcgjdkasgygjv52zaxrh63yvd85c6pl339v";
  };

  postInstall = ''
    # Without a --font argument, hiptext will try to use DejaVuSansMono.ttf from
    # the source directory.  If that file could not be found and there was no
    # --font argument provided, the program will crash.  So wrap with a default
    # --font argument.
    #
    # https://github.com/jart/hiptext/blob/da18b54c614beb74b7cb8671ea501caae2f8e85f/src/font.cc#L14
    # https://github.com/jart/hiptext/issues/12
    mkdir -p $out/share/hiptext
    cp $src/DejaVuSansMono.ttf $out/share/hiptext

    wrapProgram $out/bin/hiptext \
      --add-flags "--font $out/share/hiptext/DejaVuSansMono.ttf"
  '';

  buildInputs = [
    autoreconfHook
    freetype
    gflags
    glog
    libav
    libjpeg
    libpng
    makeWrapper
    pkgconfig
    ragel
  ];
}
