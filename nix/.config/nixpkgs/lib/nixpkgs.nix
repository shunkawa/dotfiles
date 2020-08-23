# nix-prefetch-url --unpack https://github.com/NixOS/nixpkgs-channels/archive/96745f0228359a71051a1d0bda4080e7ec134ade.tar.gz

builtins.fetchTarball {
  name = "nixpkgs-unstable-2020-08-23";
  url = https://github.com/NixOS/nixpkgs-channels/archive/ddfa22167019726c015a5638e815d028031162e8.tar.gz;
  sha256 = "03sa3h00k4qiy511gjxvpw78wdph9bn8hvfsjjq49297vavxh0cv";
}
