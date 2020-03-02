{ stdenv }:

stdenv.mkDerivation {
  name = "home-manager";

  src = fetchGit {
    url = ../../../../.nix-defexpr/home-manager;
    rev = "7bd043e9eebb0ac8c2b8a4075121cf383b81b2f2";
  };

  dontBuild = true;
  preferLocalBuild = true;

  installPhase = ''
    cp -a . $out
  '';
}
