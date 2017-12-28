{ stdenv, bundlerEnv, ruby, makeWrapper }:

stdenv.mkDerivation rec {
  name = "scss-lint-" + version;
  version = "0.52.0";

  # Avoid exposing bundler as a binary of scss-lint by creating a wrapper env.
  env = bundlerEnv {
    name = "scss-lint-" + version + "-bundle";
    inherit ruby;
    gemfile = ./Gemfile;
    lockfile = ./Gemfile.lock;
    gemset = ./gemset.nix;
  };

  buildInputs = [ makeWrapper ];

  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p $out/bin
    makeWrapper ${env}/bin/scss-lint $out/bin/scss-lint
  '';
}
