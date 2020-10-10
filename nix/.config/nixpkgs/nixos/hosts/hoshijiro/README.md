```
sudo nixos-rebuild switch -I nixpkgs="$(nix-build '<nixpkgs>' -A local-packages.nixpkgs.hoshijiro --no-out-link)" -I nixos-config=$(pwd)/configuration.nix
```
