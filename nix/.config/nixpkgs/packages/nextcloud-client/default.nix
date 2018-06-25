{ stdenv, fetchFromGitHub, cmake, pkgconfig, qtbase, qtwebkit, qtkeychain
, qttools, qtwebengine, sqlite, inotify-tools, withGnomeKeyring ? false
, makeWrapper, libgnome-keyring }:

stdenv.mkDerivation rec {
  name = "nextcloud-client-${version}";
  version = "2.5.0git"

  src = fetchFromGitHub {
    owner = "nextcloud";
    repo = "desktop";
    rev = "5d96a0e6b6e8997815c368be6e6dd6a0db53c760";
    sha256 = "0czqyq89309n4is481dfjav4i79z3a61ll9lm4lylj4b02lny1mx";
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

  postInstall = stdenv.lib.optionalString (withGnomeKeyring) ''
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
