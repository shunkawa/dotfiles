# nix-prefetch-url --unpack https://github.com/NixOS/nixpkgs-channels/archive/96745f0228359a71051a1d0bda4080e7ec134ade.tar.gz

builtins.fetchTarball {
  name = "nixpkgs-unstable-2020-08-15";
  url = https://github.com/NixOS/nixpkgs-channels/archive/96745f0228359a71051a1d0bda4080e7ec134ade.tar.gz;
  sha256 = "1jfiaib3h6gmffwsg7d434di74x5v5pbwfifqw3l1mcisxijqm3s";
}
