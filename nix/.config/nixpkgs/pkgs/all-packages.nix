{ lib, pkgs, ... }:

with pkgs;

rec {
  purs = callPackage ./purs {};
}
