{ stdenv }:

stdenv.mkDerivation {
  name = "nixos-mailserver";

  src = fetchGit {
    url = ../../../../../../.nix-defexpr/nixos-mailserver;
    rev = "bba90d3021ff4fc01e214cb3b5ab608b0f0744bc";
  };

  dontBuild = true;
  preferLocalBuild = true;

  installPhase = ''
    cp -a . $out
  '';
}
