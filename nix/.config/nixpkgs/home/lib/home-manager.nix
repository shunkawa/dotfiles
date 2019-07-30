{ stdenv }:

stdenv.mkDerivation {
  name = "home-manager";

  src = fetchGit {
    url = ../../../../.nix-defexpr/home-manager;
    rev = "5d81cb6ac772e9ef5cb285f51dfbfd13b19af854";
  };

  dontBuild = true;
  preferLocalBuild = true;

  installPhase = ''
    cp -a . $out
  '';
}
