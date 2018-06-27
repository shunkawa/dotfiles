{ stdenv }:

stdenv.mkDerivation {
  name = "nixos-mailserver";

  src = fetchGit {
    url = ../../../../../../.nix-defexpr/nixos-mailserver;
    rev = "ffc67fef469c0ec81c83b7d2681a8b2ca0c58849";
  };

  dontBuild = true;
  preferLocalBuild = true;

  installPhase = ''
    cp -a . $out
  '';
}
