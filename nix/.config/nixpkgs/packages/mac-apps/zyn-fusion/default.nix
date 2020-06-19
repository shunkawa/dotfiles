{ stdenv
, fetchurl
, alsaLib
, cairo
, cmake
, libjack2
, fftw
, fltk13
, lash
, libjpeg
, libXpm
, minixml
, ntk
, pkgconfig
, zlib
, liblo
, darwin
, mruby-zest
, fetchFromGitHub
}:
stdenv.mkDerivation rec {
  pname = "zynaddsubfx";
  version = "3.0.5";

  src = fetchurl {
    url = "mirror://sourceforge/zynaddsubfx/zynaddsubfx-${version}.tar.bz2";
    sha256 = "0qwzg14h043rmyf9jqdylxhyfy4sl0vsr0gjql51wjhid0i34ivl";
  };

  buildInputs = [
    cairo
    fftw
    libXpm
    libjpeg
    liblo
    minixml
    mruby-zest
    zlib
  ] ++ (
    stdenv.lib.optionals stdenv.isLinux [
      alsaLib
      fltk13
      lash
      libjack2
    ]
  ) ++ (
    stdenv.lib.optionals
      stdenv.isDarwin
      (with darwin.apple_sdk.frameworks; [
        Cocoa
        OpenGL
      ])
  );

  nativeBuildInputs = [ cmake pkgconfig ];

  cmakeFlags = [
    "-DDemoMode=false"
    "-DGuiModule=zest"
  ];

  patchPhase = ''
    substituteInPlace src/Misc/Config.cpp --replace /usr $out
    cp DPF/dgl/src/Window.cpp DPF/dgl/src/Window.mm
    sed -i 's/Window\.cpp/Window.mm/' src/Plugin/ZynAddSubFX/CMakeLists.txt
  '';

  fixupPhase = ''
    cp ${mruby-zest}/bin/zest $out/bin/zyn-fusion
  '';

  hardeningDisable = [
    "format"
  ];

  meta = with stdenv.lib; {
    description = "High quality software synthesizer";
    homepage = "http://zynaddsubfx.sourceforge.net";
    license = licenses.gpl2;
    platforms = platforms.unix;
    maintainers = [ maintainers.eqyiel ];
  };
}
