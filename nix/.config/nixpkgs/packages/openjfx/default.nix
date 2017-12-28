{ stdenv
, bison
, fetchurl
, ffmpeg
, gcc
, gperf
, gradle
, gstreamer
, gtk2
, jdk
, mercurial
, pkgconfig
, python3
, qt5
, ruby
, webkitgtk2
, xorg
}:

let

  # https://anonscm.debian.org/cgit/pkg-java/openjfx.git/tree/debian/patches?id=7402e3f
  gccCompatibilityPatch = ./17-gcc-compatibility.patch;

in stdenv.mkDerivation rec {
  name = "openjfx-${repover}";

  update = "121";
  build = "13";
  repover = "8u${update}-b${build}";
  src = fetchurl {
    url = "http://hg.openjdk.java.net/openjfx/8u/rt/archive/${repover}.tar.gz";
    sha256 = "0lmlzlbmp50dr9gqig35cghrncvlhr2m4q41ffppqz82gcncvbf1";
  };

  buildInputs = [
    bison
    ffmpeg
    gcc
    gperf
    gradle
    gstreamer
    gtk2
    jdk
    mercurial
    pkgconfig
    python3
    qt5.qtbase
    ruby
    webkitgtk2
    xorg.libXtst
  ];

  patchPhase = ''
    patch -p1 < ${gccCompatibilityPatch}
  '';

  buildPhase = ''
    GRADLE_USER_HOME="$(mktemp -d)" gradle sdk
  '';

  installPhase = ''
    cp -rv build/sdk $out
  '';

  meta = {
    description = "The next generation Java client toolkit.";
    homepage = http://openjdk.java.net/projects/openjfx;
    license = stdenv.lib.licenses.gpl2;
    meta.platforms = stdenv.lib.platforms.linux;
  };
}
