{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "nodenv";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "nodenv";
    repo = "nodenv";
    rev = "v${version}";
    sha256 = "01r8dycbyw3lcqpq4a79kp0zrm5a8sr2j2sazgvsgwq99c22ss0v";
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
