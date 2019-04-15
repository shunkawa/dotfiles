{ stdenv }:

stdenv.mkDerivation {
  name = "nixpkgs";

  src = fetchGit {
    url = ../../../../.nix-defexpr/nixpkgs;
    rev = "acbdaa569f4ee387386ebe1b9e60b9f95b4ab21b";
  };

  dontBuild = true;
  preferLocalBuild = true;

  installPhase = ''
    cp -a . $out
  '';
}
