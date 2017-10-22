{ pkgs, ... }:

{
  home.packages = [
    pkgs.fortune
    pkgs.local-packages.purs
  ];
}
