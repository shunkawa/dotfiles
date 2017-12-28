{ stdenv
, autoreconfHook
, fetchurl
, pkgconfig
, gdk_pixbuf
, libjpeg
, libxmlxx3
, boost
}:

stdenv.mkDerivation rec {
  name = "libopenraw-${version}";

  version = "0.1.2";

  src = fetchurl {
    url = "https://libopenraw.freedesktop.org/download/${name}.tar.bz2";
    sha256 = "10wnm43gjrp2c57v643mq4vrsffqjm48if3a64pnasnx38a8cpni";
  };

  # dontUseCmakeBuildDir = true;

  # cmakeDir = "client";

  nativeBuildInputs = [ autoreconfHook pkgconfig ];

  # enableParallelBuilding = true;

  buildInputs = [
    autoreconfHook
    gdk_pixbuf
    libjpeg
    libxmlxx3
    boost
  ];

  postConfigure = ''
    GDK_PIXBUF=$out/lib/gdk-pixbuf-2.0/2.10.0
    mkdir -p $GDK_PIXBUF/loaders
    sed -e "s#loaderdir = \$(GDK_PIXBUF_DIR)#loaderdir = $GDK_PIXBUF/loaders#" \
        -i gnome/Makefile
  '';

  preFixup = ''
    GDK_PIXBUF=$out/lib/gdk-pixbuf-2.0/2.10.0
    "${gdk_pixbuf.dev}/bin/gdk-pixbuf-query-loaders" \
      "$GDK_PIXBUF/loaders/libopenraw_pixbuf.so" > "$GDK_PIXBUF/loaders.cache"
  '';

  meta = {
    description = "RAW file parsing and processing library";
    homepage = https://libopenraw.freedesktop.org;
    license = stdenv.lib.licenses.lgpl3Plus;
    meta.platforms = stdenv.lib.platforms.linux;
  };
}
