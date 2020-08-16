{ config, lib, pkgs, ... }:

{
  nixpkgs = {
    overlays = [
      (import ../../packages/overlay.nix)
    ];
    config = {
      allowUnfree = true;
    };
  };

  nix.binaryCaches = [ "https://eqyiel.cachix.org/" ];
  nix.binaryCachePublicKeys = [ "eqyiel.cachix.org-1:aXXqq1tnHYrU0DgqT+N21rJZKLnRk6twpXW4ehRUGqg=" ];
}
