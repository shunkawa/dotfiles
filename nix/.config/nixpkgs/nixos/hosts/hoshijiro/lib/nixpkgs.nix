# nix-prefetch-url --unpack https://github.com/NixOS/nixpkgs/archive/420f89ceb267b461eed5d025b6c3c0e57703cc5c.tar.gz

builtins.fetchTarball {
  name = "nixos-unstable-2020-10-10";
  url = https://github.com/NixOS/nixpkgs/archive/420f89ceb267b461eed5d025b6c3c0e57703cc5c.tar.gz;
  sha256 = "0c9kr76p6nmf4z2j2afgcddckbaxq6kxlmp1895h6qamm1c0ypb9";
}
