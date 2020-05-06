{ stdenv }:

stdenv.mkDerivation rec {
  name = "nixpkgs";

  src = fetchGit {
    url = ../../../../../../.nix-defexpr/nixpkgs;
    rev = "fce7562cf46727fdaf801b232116bc9ce0512049";
  };

  dontBuild = true;
  preferLocalBuild = true;

  installPhase = ''
    cp -a . $out
  '';
}
