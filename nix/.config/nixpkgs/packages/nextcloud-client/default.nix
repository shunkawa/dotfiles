{ stdenv, fetchFromGitHub, cmake, pkgconfig, qtbase, qtwebkit, qtkeychain
, qttools, qtwebengine, sqlite, inotify-tools, withGnomeKeyring ? false
, makeWrapper, libgnome-keyring, openssl }:

stdenv.mkDerivation rec {
  name = "nextcloud-client-${version}";
  version = "2.5.0git";

  src = fetchFromGitHub {
    owner = "nextcloud";
    repo = "desktop";
    rev = "17d4aeeb78c94b2fe7af49e9b8e25d3e9f0a3286";
    sha256 = "1pv289xib6pzxaccbpymnch2vk65iwxl85gsz4pjnxcrfvql3nhm";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ pkgconfig cmake ];

  buildInputs = [
    qtbase qtkeychain qttools qtwebengine qtwebkit sqlite openssl
  ] ++ stdenv.lib.optional stdenv.isLinux inotify-tools
    ++ stdenv.lib.optional withGnomeKeyring makeWrapper;

  enableParallelBuilding = true;

  cmakeFlags = [
    "-UCMAKE_INSTALL_LIBDIR"
    "-DCMAKE_BUILD_TYPE=Release"
    "-DOPENSSL_INCLUDE_DIR=${openssl.dev}/include"
    "-DOPENSSL_CRYPTO_LIBRARY=${openssl.out}/lib/libcrypto.so"
    "-DOPENSSL_SSL_LIBRARY=${openssl.out}/lib/libssl.so"
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
