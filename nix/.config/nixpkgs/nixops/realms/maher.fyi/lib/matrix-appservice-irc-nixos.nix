{ stdenv }:

stdenv.mkDerivation {
  name = "matrix-appservice-irc-nixos";

  src = fetchGit {
    url = ../../../../../../.nix-defexpr/matrix-appservice-irc-nixos;
    rev = "82e510a46f9523e35df340e134abef998b7bab39";
  };

  dontBuild = true;
  preferLocalBuild = true;

  installPhase = ''
    cp -a . $out
  '';
}
