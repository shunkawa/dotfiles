# nix-prefetch-url --unpack https://github.com/rycee/home-manager/archive/a3dd580adc46628dd0c970037b6c87cff1251af5.tar.gz

builtins.fetchTarball {
  name = "home-manager-2020-08-15";
  url = https://github.com/rycee/home-manager/archive/a3dd580adc46628dd0c970037b6c87cff1251af5.tar.gz;
  sha256 = "13qplav382kd7gblvxqi0zxnj0pdvm28pxdimxlj0d36ks3xl0rf";
}
