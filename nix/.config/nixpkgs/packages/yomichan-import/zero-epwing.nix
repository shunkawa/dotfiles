{ stdenv
, cmake
, eb
, fetchFromGitHub
, jansson
, libiconv
, pkgconfig
, zlib
}:
let
  # This should be the same as the revision of zero-epwing pinned in https://github.com/FooSoft/yomichan-import
  rev = "ea42fab71b75be3b9a3ebe6fc37bae2eac16e44a";
in
stdenv.mkDerivation {
  name = "zero-epwing-${rev}";
  version = rev;
  buildInputs = [
    cmake
    eb
    jansson
    libiconv
    pkgconfig
    zlib
  ];

  src = fetchFromGitHub {
    owner = "FooSoft";
    repo = "zero-epwing";
    sha256 = "0rfcawzhdnxi4phmh1ybac3674ck4m8bpra1ii0hpy0iid6gv93a";
    inherit rev;
    fetchSubmodules = true;
  };

  postPatch = ''
    substituteInPlace "book.c" --replace "jansson/include/jansson.h" "jansson.h"
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp zero-epwing $out/bin
  '';


  meta = with stdenv.lib; {
    description = "Zero-EPWING is a tool built to export easy to process JSON formatted UTF-8 data from dictionaries in EPWING format.";
    homepage = https://github.com/FooSoft/zero-epwing;
    license = licenses.mit;
    maintainers = with maintainers; [ eqyiel ];
    platforms = platforms.unix;
  };

}
