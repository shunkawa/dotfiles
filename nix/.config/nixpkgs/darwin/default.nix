{ config, lib, pkgs, ... }:

{
  imports = [
    ./../pkgs/overrides.nix
    ./environment.nix
    ./nixpkgs.nix
  ];
}
