self: super: rec {
  home = {
    home-manager-src = (super.callPackage ({ stdenv }: stdenv.mkDerivation {
      name = "home-manager";

      src = fetchGit {
        url = ../../.././.nix-defexpr/home-manager;
        rev = "99c900946dbbaf5ba1fd3b1c1fe83b18fb66c84e";
      };

      dontBuild = true;
      preferLocalBuild = true;

      installPhase = ''
        cp -a . $out
      '';
    }) {});

    home-manager = import "${self.home.home-manager-src}/overlay.nix" self super;
  };
}
