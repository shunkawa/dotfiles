self: super: {
  local-packages = import ./all-packages.nix {
    inherit (super) lib pkgs;
  };
}
