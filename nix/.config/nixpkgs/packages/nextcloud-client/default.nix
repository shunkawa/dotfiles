{ stdenv, fetchFromGitHub, cmake, pkgconfig, qtbase, qtwebkit, qtkeychain
, qttools, qtwebengine, sqlite, inotify-tools, withGnomeKeyring ? false
, makeWrapper, libgnome-keyring }:

stdenv.mkDerivation rec {
  name = "nextcloud-client-${version}";
  version = "2.5.0-beta2";

  src = fetchFromGitHub {
    owner = "nextcloud";
    repo = "desktop";
    rev = "82f3b4c91fe4dc6f6c8c18cda9e0fe079671601b";
    sha256 = "18m82pk4998gdwswspq9bqnz33j4ahjs2waxwybb9wl68f638zy9";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ pkgconfig cmake ];

  buildInputs = [ qtbase qtkeychain qttools qtwebengine qtwebkit sqlite ]
    ++ stdenv.lib.optional stdenv.isLinux inotify-tools
    ++ stdenv.lib.optional withGnomeKeyring makeWrapper;

  enableParallelBuilding = true;

  cmakeFlags = [
    "-UCMAKE_INSTALL_LIBDIR"
    "-DCMAKE_BUILD_TYPE=Release"
  ] ++ stdenv.lib.optionals stdenv.isLinux [
    "-DINOTIFY_LIBRARY=${inotify-tools}/lib/libinotifytools.so"
    "-DINOTIFY_INCLUDE_DIR=${inotify-tools}/include"
  ];

  postInstall = ''
    sed -i 's/\(Icon.*\)=nextcloud/\1=Nextcloud/g' \
      $out/share/applications/nextcloud.desktop
  '' + stdenv.lib.optionalString (withGnomeKeyring) ''
      wrapProgram "$out/bin/nextcloud" \
        --prefix LD_LIBRARY_PATH : ${stdenv.lib.makeLibraryPath [ libgnome-keyring ]}
  '';

  meta = with stdenv.lib; {
    description = "Nextcloud themed desktop client";
    homepage = https://nextcloud.com;
    license = licenses.gpl2;
    maintainers = with maintainers; [ caugner ];
    platforms = platforms.linux;
  };
}
