{ stdenv }: stdenv.mkDerivation {
  name = "home-manager";

  src = fetchGit {
    url = ../../../../../../../.nix-defexpr/home-manager;
    rev = "5641ee3f942e700de35b28fc879b0d8a10a7a1fe";
  };

  dontBuild = true;
  preferLocalBuild = true;

  installPhase = ''
    cp -a . $out
  '';
}
