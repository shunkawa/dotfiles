{ pkgs, localPackages, ...}:

with pkgs; [
  haskellPackages.cabal2nix
]
