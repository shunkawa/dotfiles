  { pkgs ? import <nixpkgs> {}
, system ? builtins.currentSystem
, nodejs ? pkgs.nodejs-6_x
, grunt ? pkgs.nodePackages.grunt-cli
, scss-lint
}:

let
  nodePackages = import ./composition.nix {
    inherit pkgs system nodejs;
  };
  inherit (nodejs) python;
  inherit (pkgs) ruby gcc gnumake;
in
nodePackages // {
  "rsvp.fyi-client" = nodePackages."rsvp.fyi-client".override {
    buildInputs = [
      gcc
      gnumake
      grunt
      nodejs
      python
      ruby
      scss-lint
    ];
    postInstall = ''
      grunt build &&
      cp -r dist/* $out
      # Don't include node_modules
      rm -rf $out/lib
    '';
  };
}
