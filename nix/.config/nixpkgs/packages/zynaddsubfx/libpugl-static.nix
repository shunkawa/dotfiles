{ stdenv
, wafHook
, fetchFromGitHub
, Cocoa
}:

stdenv.mkDerivation {
  name = "pugl";
  version = "HEAD";

  src = fetchFromGitHub (import ./mruby-zest-src.nix);

  preConfigure = ''
    cd deps/pugl
  '';

  buildInputs = [ wafHook ] ++ stdenv.lib.optionals stdenv.isDarwin [ Cocoa ];

  wafConfigureFlags = [ " --no-cairo" "--static" ];
}
