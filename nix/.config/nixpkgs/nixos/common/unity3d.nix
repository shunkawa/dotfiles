{ config, lib, pkgs, ... }:

{
  environment.systemPackages = [ pkgs.unity3d ];

  security.chromiumSuidSandbox.enable = true;

  nixpkgs.config.allowUnfree = true;
}
