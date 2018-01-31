{ stdenv, fetchFromGitHub, haskellPackages }:

# nix-prefetch-git https://github.com/jwiegley/hnix.git --rev a28a839
stdenv.lib.id (haskellPackages.callPackage ((fetchFromGitHub {
  owner = "jwiegley";
  repo = "hnix";
  rev = "a28a8397cdca2834308f6b67ce354f50025cc8d0";
  sha256 = "0ay662k0xzgdc32pv90sjf37nd2a8r1vw7x2hry18zkklhqmyjn4";
}) + "/default.nix") {})
