{ stdenv }:

stdenv.mkDerivation {
  name = "nixpkgs";

  src = fetchGit {
    url = ../../../../.nix-defexpr/nixpkgs;
    rev = "d072c8c9063679b19e622fe8e80d81ea8b91bf38";
  };

  dontBuild = true;
  preferLocalBuild = true;

  installPhase = ''
    cp -a . $out
  '';
}
