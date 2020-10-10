let
  nixpkgsSrc = builtins.fetchTarball https://github.com/NixOS/nixpkgs/archive/e544e03110063eee62ca1f1b407c4f7e0739c432.tar.gz;
in (import "${nixpkgsSrc}/nixos/lib/eval-config.nix" { modules = [ (import ./configuration.nix { inherit nixpkgsSrc; }) ]; }).config.system.build.sdImage
