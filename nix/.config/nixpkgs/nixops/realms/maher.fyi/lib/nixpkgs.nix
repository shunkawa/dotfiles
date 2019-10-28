{ stdenv }:

stdenv.mkDerivation {
  name = "nixpkgs";

  src = fetchGit {
    url = ../../../../../../.nix-defexpr/nixpkgs;
    rev = "4641f957913f8a69b774111e0fc5c0cd30e5d26f";
  };

  dontBuild = true;
  preferLocalBuild = true;

  installPhase = ''
    cp -a . $out
  '';
}
