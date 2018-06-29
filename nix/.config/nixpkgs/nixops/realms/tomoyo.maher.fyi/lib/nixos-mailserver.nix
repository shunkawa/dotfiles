{ stdenv }:

stdenv.mkDerivation {
  name = "nixos-mailserver";

  src = fetchGit {
    url = ../../../../../../.nix-defexpr/nixos-mailserver;
    rev = "3aecb1299d3fe26c3946198645b4d69530c8fb3f";
  };

  dontBuild = true;
  preferLocalBuild = true;

  installPhase = ''
    cp -a . $out
  '';
}
