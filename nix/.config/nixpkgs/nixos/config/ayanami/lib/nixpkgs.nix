{ stdenv }:

stdenv.mkDerivation rec {
  name = "nixpkgs";

  src = fetchGit {
    url = ../../../../../../.nix-defexpr/nixpkgs;
    rev = "7c20ec04377a36cbf2e070ba2d3300fbf95666ea";
  };

  dontBuild = true;
  preferLocalBuild = true;

  installPhase = ''
    cp -a . $out
  '';
}
