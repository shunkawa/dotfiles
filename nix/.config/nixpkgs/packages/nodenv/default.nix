{ stdenv, fetchFromGitHub }:
let
  versions = builtins.fromJSON (builtins.readFile ./versions.json);
in
stdenv.mkDerivation rec {
  name = "nodenv";
  version = versions.nodenv.rev;

  src = fetchFromGitHub {
    owner = "nodenv";
    repo = "nodenv";
    inherit (versions.nodenv) rev sha256;
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin
    mv libexec $out
    ln -s $out/libexec/nodenv $out/bin/nodenv

    mkdir -p $out/etc/bash_completion.d
    mkdir -p $out/share/fish/completions
    mkdir -p $out/share/zsh/site-functions

    # Upstream's zsh completions are broken.
    cp ${./_nodenv} $out/share/zsh/site-functions/_nodenv
    mv completions/nodenv.fish $out/share/fish/completions
    mv completions/nodenv.bash $out/etc/bash_completion.d
  '';
}
