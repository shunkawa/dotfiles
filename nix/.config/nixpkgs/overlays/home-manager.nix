self: super: rec {
  home = {
    nixpkgs = (super.callPackage ../home/lib/nixpkgs.nix {});

    home-manager-src = (super.callPackage ({ stdenv, fetchFromGitHub }: stdenv.mkDerivation {
      name = "home-manager";
      src = fetchFromGitHub {
        owner = "rycee";
        repo = "home-manager";
        rev = "5641ee3f942e700de35b28fc879b0d8a10a7a1fe";
        sha256 = "0bqzwczbr5c2y3ms7m7ly0as9zsnqwljq61ci2y2gbqzw3md1x2j";
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
