self: super: rec {
  home = {
    home-manager-src = (super.callPackage ({ stdenv }: stdenv.mkDerivation {
      name = "home-manager";

      src = fetchGit {
        url = ../../.././.nix-defexpr/home-manager;
        rev = "34db8df6d91d8c142435d0d66bad50a6b2c090f0";
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
