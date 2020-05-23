{ ... }:

{
  imports = [
    ./config
  ] ++ (import ./modules/module-list.nix);
}
