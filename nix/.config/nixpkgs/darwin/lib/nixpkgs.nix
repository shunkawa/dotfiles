{ stdenv }:

stdenv.mkDerivation rec {
  name = "nixpkgs";

  src = fetchGit {
    url = ../../../../.nix-defexpr/nixpkgs;
    rev = "373488e6f4c3dc3bb51cabcb959e4a70eb5d7b2c";
  };

  dontBuild = true;
  preferLocalBuild = true;

  installPhase = ''
    cp -a . $out
  '';
}
