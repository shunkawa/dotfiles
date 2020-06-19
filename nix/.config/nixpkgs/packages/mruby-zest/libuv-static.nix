{ stdenv, lib, fetchFromGitHub, autoconf, automake, libtool, pkgconfig, ApplicationServices, CoreServices }:

stdenv.mkDerivation rec {
  version = "1.9.1";
  pname = "libuv";

  src = fetchFromGitHub {
    owner = pname;
    repo = pname;
    rev = "v${version}";
    sha256 = "1kc386gkkkymgz9diz1z4r8impcsmki5k88dsiasd6v9bfvq04cc";
  };

  nativeBuildInputs = [ automake autoconf libtool pkgconfig ];
  buildInputs = stdenv.lib.optionals stdenv.isDarwin [ ApplicationServices CoreServices ];

  preConfigure = ''
    LIBTOOLIZE=libtoolize ./autogen.sh
  '';

  enableParallelBuilding = true;

  doCheck = false;

  configureFlags = [ "--enable-static" "--disable-shared" ];

  meta = with lib; {
    description = "A multi-platform support library with a focus on asynchronous I/O";
    homepage = "https://github.com/libuv/libuv";
    maintainers = with maintainers; [ eqyiel ];
    platforms = with platforms; linux ++ darwin;
    license = with licenses; [ mit isc bsd2 bsd3 cc-by-40 ];
  };

}
