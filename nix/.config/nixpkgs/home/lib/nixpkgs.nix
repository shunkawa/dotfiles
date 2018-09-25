{ stdenv }:

stdenv.mkDerivation {
  name = "nixpkgs";

  src = fetchGit {
    url = ../../../../.nix-defexpr/nixpkgs;
    rev = "c1a30680eb4bd4c460630253fc83bc66e91e23cb";
  };

  dontBuild = true;
  preferLocalBuild = true;

  installPhase = ''
    cp -a . $out
  '';
}
