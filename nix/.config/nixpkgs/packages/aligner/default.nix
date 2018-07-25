{ stdenv, fetchFromGitHub, rustPlatform, makeWrapper }:

rustPlatform.buildRustPackage rec {
  name = "aligner";

  src = fetchFromGitHub {
    owner = "kaegi";
    repo = "aligner";
    rev = "00facc0a05539719e085507ca479a5d46b0bcf49";
    sha256 = "1lz4zkiv9qybqbakj7gfw6m0lz1amzznwcp44w92frv5vgns3r0f";
  };

  cargoSha256 = "1azf19yjrdw5mk2j9lc7aa4kh2ddq50a3b86nn6dbvca7h6vl39p";

  meta = {
    description = ''Tool that corrects a subtitle given a second "correct" subtitle'';
    homepage = https://github.com/kaegi/aligner;
    license = stdenv.lib.licenses.gpl3;
  };
}
