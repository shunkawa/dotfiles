{ pkgs ? import <nixpkgs> {
    inherit system;
  }
, system ? builtins.currentSystem
, nodejs ? pkgs."nodejs-12_x"
}:
(import ./composition.nix {
  inherit pkgs;
  inherit system;
  inherit nodejs;
}
)."markdown-lint-./"
