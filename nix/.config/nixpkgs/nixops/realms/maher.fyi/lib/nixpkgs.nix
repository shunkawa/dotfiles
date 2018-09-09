{ stdenv }:

stdenv.mkDerivation {
  name = "nixpkgs";

  src = fetchGit {
    url = ../../../../../../.nix-defexpr/nixpkgs;
    rev = "747af3b7ce2443f402e1e35039d7c47674b06fc0";
  };

  dontBuild = true;
  preferLocalBuild = true;

  installPhase = ''
    cp -a . $out
  '';
}
