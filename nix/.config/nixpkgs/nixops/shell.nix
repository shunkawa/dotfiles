{ nixpkgs ? <nixpkgs>, system ? builtins.currentSystem }:

let
  nixpkgsLocal = import nixpkgs { inherit system; };

  nixpkgsUnstable = (import (nixpkgsLocal.callPackage ./nix/nixpkgs.nix {}) {
    inherit system;
    overlays = [ (import ./nix/overlay.nix) ];
  });
in with nixpkgsUnstable.pkgs; stdenv.mkDerivation rec {
  name = "deployments-env";
  env = buildEnv { name = name; paths = buildInputs; };
  buildInputs = (import ./nix/make-build-inputs.nix { inherit pkgs lib; });
  shellHook = ''
    echo ✨ environment ready!
  '';
}
