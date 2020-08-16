{ stdenv
, AppKit
, buildGoPackage
}:
let
  rev = "fc189b9b833879fe0bda7bedc5e2e30644a122e2";
in
buildGoPackage rec {
  name = "yomichan-import-${version}";

  version = rev;

  goDeps = ./deps.nix;

  goPackagePath = "github.com/FooSoft/yomichan-import";

  buildInputs = stdenv.lib.optional stdenv.isDarwin AppKit;

  src = builtins.fetchGit {
    url = ./yomichan-import;
    inherit rev;
  };

  patches = [ ./use-zero-epwing-from-PATH.patch ];

  meta = with stdenv.lib; {
    description = "Yomichan Import allows users of the Yomichan extension to import custom dictionary files.";
    homepage = https://github.com/FooSoft/yomichan-import;
    license = licenses.mit;
    maintainers = with maintainers; [ eqyiel ];
    platforms = platforms.unix;
  };
}
