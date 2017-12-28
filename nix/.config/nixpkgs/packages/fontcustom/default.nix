{ stdenv, bundlerEnv, ruby, makeWrapper, sfnt2woff, fontforge }:

# Make sure you're using a version of fontforge that was compiled with python
# scripting enabled.

stdenv.mkDerivation rec {
  name = "fontcustom-" + version;
  version = "1.3.8";

  # Avoid exposing bundler as a binary of fontcustom by creating a wrapper env.
  env = bundlerEnv {
    name = "fontcustom-" + version + "-bundle";
    inherit ruby;
    gemfile = ./Gemfile;
    lockfile = ./Gemfile.lock;
    gemset = ./gemset.nix;
  };

  buildInputs = [ makeWrapper fontforge sfnt2woff ];
  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p $out/bin
    makeWrapper ${env}/bin/fontcustom $out/bin/fontcustom \
      --prefix PATH : "${fontforge}/bin:$PATH"
  '';
}
