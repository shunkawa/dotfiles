{ stdenv
, fetchFromGitHub
, cmake
, autoreconfHook
}:
let
  rev = "bc5741fb1ac730ead24e9bd08977fc6c248e04b0";
in
stdenv.mkDerivation {
  name = "jansson-${rev}";
  version = rev;
  buildInputs = [ cmake autoreconfHook ];

  src = fetchFromGitHub {
    owner = "akheron";
    repo = "jansson";
    inherit rev;
    sha256 = "1vyh6y0xczw94qchm3s2czvdjn47kv8cmymxzsnk5nxnnrb74s2f";
  };

  meta = with stdenv.lib; {
    description = "Jansson is a C library for encoding, decoding and manipulating JSON data.";
    homepage = https://github.com/akheron/jansson;
    license = licenses.mit;
    maintainers = with maintainers; [ eqyiel ];
    platforms = platforms.unix;
  };

}
