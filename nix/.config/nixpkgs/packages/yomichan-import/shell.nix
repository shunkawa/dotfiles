{ system ? builtins.currentSystem }:

with (
  import
    (builtins.fetchTarball {
      name = "nixpkgs-unstable-2020-08-15";
      url = "https://github.com/nixos/nixpkgs-channels/archive/96745f0228359a71051a1d0bda4080e7ec134ade.tar.gz";
      sha256 = "1jfiaib3h6gmffwsg7d434di74x5v5pbwfifqw3l1mcisxijqm3s";
    }) {
    inherit system;
    # overlays = [
    #   (self: super: {
    #     nur =
    #       import
    #         (builtins.fetchTarball {
    #           name = "nur-2020-08-15";
    #           url = "https://github.com/nix-community/NUR/archive/b9649a747e43c62f50829f87426c02ac0a7c5364.tar.gz";
    #           sha256 = "0fbrwk5bd8mirrkhhnlx8ln9d9lp8bw1lz4s8wxz61m3gh0g2qii";
    #         }) { inherit (super) pkgs; };
    #   })
    # ];
  }
); mkShell {
  buildInputs = [
    vgo2nix
  ];
  shellHook = ''
    echo ✨ environment ready!
  '';
}
