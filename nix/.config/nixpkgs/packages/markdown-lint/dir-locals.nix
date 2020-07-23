{ system ? builtins.currentSystem }:

with (import (import ./nixpkgs.nix) { inherit system; });

pkgs.nixBufferBuilders.withPackages
  (import ./shell.nix { }).buildInputs
