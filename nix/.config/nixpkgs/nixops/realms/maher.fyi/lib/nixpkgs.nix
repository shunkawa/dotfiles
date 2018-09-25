{ stdenv }:

stdenv.mkDerivation {
  name = "nixpkgs";

  src = fetchGit {
    url = ../../../../../../.nix-defexpr/nixpkgs;
    rev = "c5a64e02fdcc7a055b2e3385de6fb6d742f71509";
  };

  dontBuild = true;
  preferLocalBuild = true;

  installPhase = ''
    cp -a . $out
  '';
}
