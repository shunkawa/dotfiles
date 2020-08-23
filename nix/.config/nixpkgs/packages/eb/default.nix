{ stdenv
, fetchFromGitHub
, cmake
, pkgconfig
, zlib
}:
let
  rev = "c9d1015f9ec4fdc3936f8d3905ccb7b1145eb1cf";
in
stdenv.mkDerivation {
  name = "eb-${rev}";
  version = rev;

  src = fetchFromGitHub {
    owner = "FooSoft";
    repo = "eb";
    inherit rev;
    sha256 = "18j25lpcahfjm4y687kzr797mnri839sk0n74gl1vjx1nm019l7k";
  };

  configurePhase = ''
    ./configure --disable-shared --disable-ebnet --disable-nls --prefix $out
  '';

  buildInputs = [ cmake pkgconfig zlib ];

  meta = with stdenv.lib; {
    description = "This is a fork of the last known release of eb (a.k.a. eblib, libeb), version 4.4.3. It includes fixes for the Windows operating system as well as a capability to dump all data out of EPWING dictionaries (as opposed to simply executing search queries).";
    homepage = https://github.com/FooSoft/eb;
    license = licenses.mit; # based off the text in "COPYING"
    maintainers = with maintainers; [ eqyiel ];
    platforms = platforms.unix;
  };
}
