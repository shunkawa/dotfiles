{ stdenv }:

stdenv.mkDerivation rec {
  name = "nixpkgs";

  src = fetchGit {
    url = ../../../../../../.nix-defexpr/nixpkgs;
    rev = "7db611f2af869bac6e31ba814a5593c52d54ec19";
  };

  dontBuild = true;
  preferLocalBuild = true;

  installPhase = ''
    cp -a . $out
  '';
}
