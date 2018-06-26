{ stdenv }:

stdenv.mkDerivation rec {
  name = "nixpkgs";

  src = fetchGit {
    url = ../../../../../../.nix-defexpr/nixpkgs;
    rev = "a8c71037e041725d40fbf2f3047347b6833b1703";
  };

  dontBuild = true;
  preferLocalBuild = true;

  installPhase = ''
    cp -a . $out
  '';
}
