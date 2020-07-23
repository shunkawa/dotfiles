{ stdenv
, AppKit
, Cocoa
, OpenGL
, alsaLib
, cairo
, cmake
, fetchFromGitHub
, fetchurl
, fftw
, lash
, libjack2
, libjpeg
, liblo
, minixml
, mruby-zest
, pkgconfig
, zlib
}:
stdenv.mkDerivation rec {
  pname = "zynaddsubfx";
  version = "3.0.5";

  src = fetchurl {
    url = "mirror://sourceforge/zynaddsubfx/zynaddsubfx-${version}.tar.bz2";
    sha256 = "0qwzg14h043rmyf9jqdylxhyfy4sl0vsr0gjql51wjhid0i34ivl";
  };

  buildInputs = [
    fftw
    libjpeg
    liblo
    minixml
    mruby-zest
    zlib
  ] ++ (
    stdenv.lib.optionals stdenv.isLinux [
      alsaLib
      lash
      libjack2
    ]
  ) ++ (
    stdenv.lib.optionals
      stdenv.isDarwin
      [ Cocoa OpenGL ]
  );

  nativeBuildInputs = [ cmake pkgconfig ];

  cmakeFlags = [
    "-DGuiModule=zest"
    "-DBuildForDebug=true"
    "-DDemoMode=false"
    "-DCMAKE_BUILD_TYPE=None"
    ''-DCMAKE_EXE_LINKER_FLAGS="-static-libstdc++"''
    ''-DCMAKE_SHARED_LINKER_FLAGS="-static-libstdc++"''
    "-DCMAKE_SKIP_BUILD_RPATH=ON"
    "-DNoNeonPlease=ON"
  ];

  prePatch = ''
    substituteInPlace src/Misc/Config.cpp --replace /usr $out
  '' + (
    if stdenv.isDarwin then ''
       ##  Window.cpp needs to be compiled as obj-c++
      cp DPF/dgl/src/Window.cpp DPF/dgl/src/Window.mm
      sed -i 's/Window\.cpp/Window.mm/' src/Plugin/ZynAddSubFX/CMakeLists.txt
    ''
    else ""
  );

  postInstall = ''
    # not necessary if LV2_PATH is set
    ln -s ${mruby-zest}/opt/zyn-fusion/qml $out/lib/lv2/ZynAddSubFX.lv2/qml
    ln -s ${mruby-zest}/opt/zyn-fusion/schema $out/lib/lv2/ZynAddSubFX.lv2/schema
    ln -s ${mruby-zest}/opt/zyn-fusion/font $out/lib/lv2/ZynAddSubFX.lv2/font
    ln -s ${mruby-zest}/opt/zyn-fusion/libzest.dylib $out/lib/lv2/ZynAddSubFX.lv2/libzest.dylib

    cp -v ${mruby-zest}/opt/zyn-fusion/zyn-fusion $out/bin/zyn-fusion
    cp -v ${mruby-zest}/opt/zyn-fusion/libzest.dylib $out/bin/libzest.dylib

    rm -rf $out/lib/vst
    # ZynAddSubFX deliberately ships without a "standalone" application on
    # macOS:
    # https://sourceforge.net/p/zynaddsubfx/mailman/message/36272025/
    rm -rf $out/bin
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
