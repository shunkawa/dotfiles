{ stdenv }: stdenv.mkDerivation {
  name = "home-manager";

  src = fetchGit {
    url = ../../../../../../.nix-defexpr/home-manager;
    rev = "a28614e65d2ff0e78fe54ca6ec31cc042f563669";
  };

  dontBuild = true;
  preferLocalBuild = true;

  installPhase = ''
    cp -a . $out
  '';
}
