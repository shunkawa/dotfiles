{ stdenv }:

stdenv.mkDerivation rec {
  name = "nixpkgs";

  src = fetchGit {
    url = ../../../../../../.nix-defexpr/nixpkgs;
    rev = "8395f9aa85e621c076334a67d814de8221ce7983";
  };

  dontBuild = true;
  preferLocalBuild = true;

  installPhase = ''
    cp -a . $out
  '';
}
