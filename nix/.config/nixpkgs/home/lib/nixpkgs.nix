{ stdenv }:

stdenv.mkDerivation {
  name = "nixpkgs";

  src = fetchGit {
    url = ../../../../.nix-defexpr/nixpkgs;
    rev = "5f67e95e0450a764df1e2ff703507e97eac31e04";
  };

  dontBuild = true;
  preferLocalBuild = true;

  installPhase = ''
    cp -a . $out
  '';
}
