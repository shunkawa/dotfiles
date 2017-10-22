self: super: {
  local-packages = import ./../pkgs/all-packages.nix {
    inherit (super) lib pkgs;
  };
}
