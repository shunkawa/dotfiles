{ callPackage, darwin }:
rec {
  libpugl-static = callPackage ./libpugl-static.nix {
    inherit (darwin.apple_sdk.frameworks) Cocoa;
  };

  libuv-static = callPackage ./libuv-static.nix {
    inherit (darwin.apple_sdk.frameworks) ApplicationServices CoreServices;
  };

  mruby-zest = callPackage ./mruby-zest.nix {
    inherit libpugl-static;
    inherit libuv-static;
    inherit (darwin.apple_sdk.frameworks) Cocoa OpenGL;
  };

  zynaddsubfx = callPackage ./zynaddsubfx-zest-ui.nix {
    inherit mruby-zest;
    inherit (darwin.apple_sdk.frameworks) Cocoa OpenGL;
  };
}
