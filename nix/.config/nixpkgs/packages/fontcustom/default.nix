{ stdenv
, bundlerEnv
, eot_utilities
, fontforge
, makeWrapper
, ruby
, sfnt2woff-zopfli
, woff2
, python
}:

# Make sure you're using a version of fontforge that was compiled with python
# scripting enabled.

stdenv.mkDerivation rec {
  name = "fontcustom-" + version;
  version = "2.0.0";

  # Avoid exposing bundler as a binary of fontcustom by creating a wrapper env.
  env = bundlerEnv {
    name = "fontcustom-" + version + "-bundle";
    inherit ruby;
    gemfile = ./Gemfile;
    lockfile = ./Gemfile.lock;
    gemset = ./gemset.nix;
  };

  buildInputs = [
    eot_utilities
    fontforge
    makeWrapper
    sfnt2woff-zopfli
    woff2
  ];

  unpackPhase = "true";

  installPhase = ''
    mkdir -p $out/bin
    makeWrapper ${env}/bin/fontcustom $out/bin/fontcustom \
      --prefix PATH : "${woff2}/bin" \
      --prefix PATH : "${fontforge}/bin" \
      --prefix PATH : "${sfnt2woff-zopfli}/bin" \
      --prefix PATH : "${eot_utilities}/bin"
  '';
}
