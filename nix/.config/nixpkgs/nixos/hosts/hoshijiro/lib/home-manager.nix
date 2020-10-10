# nix-prefetch-url --unpack https://github.com/rycee/home-manager/archive/473d9acdadc2969ba2b5c1c55b440fdda5d213e5.tar.gz

builtins.fetchTarball {
  name = "home-manager-2020-10-10";
  url = https://github.com/rycee/home-manager/archive/473d9acdadc2969ba2b5c1c55b440fdda5d213e5.tar.gz;
  sha256 = "0kb61qg8gwbm45r4f3swsx1fpqlvvh3vz0dzxq9b5lpkqpdig77q";
}
