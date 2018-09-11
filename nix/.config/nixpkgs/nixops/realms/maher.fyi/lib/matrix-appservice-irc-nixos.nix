{ stdenv }:

stdenv.mkDerivation {
  name = "matrix-appservice-irc-nixos";

  src = fetchGit {
    url = ../../../../../../.nix-defexpr/matrix-appservice-irc-nixos;
    rev = "f0842d656ce55e1071ee3eab7d9aae9d429dca00";
  };

  dontBuild = true;
  preferLocalBuild = true;

  installPhase = ''
    cp -a . $out
  '';
}
