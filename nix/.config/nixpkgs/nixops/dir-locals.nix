{ nixpkgs ? <nixpkgs>, system ? builtins.currentSystem }:

with (import nixpkgs {
  inherit system;
  overlays = [ (import ./nix/overlay.nix) ];
}); pkgs.nixBufferBuilders.withPackages (import ./shell.nix {}).buildInputs
