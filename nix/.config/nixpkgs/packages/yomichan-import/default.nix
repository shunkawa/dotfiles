{ stdenv
, makeWrapper
, yomichan-import
, zero-epwing
}: stdenv.mkDerivation {
  inherit (yomichan-import) name version;

  phases = [ "installPhase" ];

  buildInputs = [ makeWrapper ];

  installPhase = ''
    makeWrapper ${yomichan-import}/bin/yomichan-import $out/bin/yomichan-import --prefix PATH ":" ${
      stdenv.lib.makeBinPath [ zero-epwing ]
    }
  '';
}
