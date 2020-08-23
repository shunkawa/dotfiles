{ stdenv
, cmake
, eb
, fetchFromGitHub
, makeWrapper
, pkgconfig
, qtbase
, qtmultimedia
, qttools
, qtwebengine
, zlib
}:

stdenv.mkDerivation rec {
  name = "qolibri";
  version = "2.1.3";

  src = fetchFromGitHub {
    repo = "qolibri";
    owner = "ludios";
    rev = version;
    sha256 = "03ca0pscpghnfdmf7i5k14g5rlv4zaj4m29vn8mbj97b431hz3cx";
  };

  buildInputs = [
    cmake
    eb
    pkgconfig
    qtbase
    qtmultimedia
    qttools
    qtwebengine
    zlib
    makeWrapper
  ];

  postInstall = ''
    mkdir -p $out/Applications
    mv qolibri.app $out/Applications

    wrapProgram $out/Applications/qolibri.app/Contents/MacOS/qolibri \
      --set QT_QPA_PLATFORM_PLUGIN_PATH ${qtbase.bin}/lib/qt-*/plugins/platforms

    rm -rf $out/bin
  '';

  meta = with stdenv.lib; {
    description = "Continuation of the qolibri EPWING dictionary/book reader.";
    homepage = https://github.com/ludios/qolibri;
    license = licenses.mit;
    maintainers = with maintainers; [ eqyiel ];
    platforms = platforms.unix;
  };
}
