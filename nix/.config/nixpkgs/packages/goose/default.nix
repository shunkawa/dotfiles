{ stdenv, fetchFromGitHub, buildGoPackage, darwin }:

buildGoPackage {
  pname = "goose";
  version = "2.6.0";

  goPackagePath = "github.com/pressly/goose";

  # subPackages = [ "cmd/goose" ];

  src = fetchGit {
    url = ./src/github.com/pressly/goose;
    rev = "e4b98955473e91a12fc7d8816c28d06376d1d92c";
  };

  goDeps = ./deps.nix;
}
