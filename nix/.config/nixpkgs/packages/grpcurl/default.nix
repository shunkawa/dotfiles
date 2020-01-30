{ stdenv, fetchFromGitHub, buildGoPackage, darwin }:

buildGoPackage rec {
  pname = "kazegusuri";
  version = "0.0.0-" + builtins.substring 0 7 rev;

  rev = "a582134f889f20ad95425e7bb9c667930dedc053";

  goPackagePath = "github.com/kazegusuri/grpcurl";

  src = fetchGit {
    inherit rev;
    url = ./src/github.com/kazegusuri/grpcurl;
  };

  goDeps = ./deps.nix;
}
