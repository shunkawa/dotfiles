{ stdenv
, bison
, darwin
, fetchFromGitHub
, libuv
, python2
, rake
, ruby
, wget
, callPackage
}:
let
  libuv-static = callPackage ./libuv-static.nix {
    inherit (darwin.apple_sdk.frameworks) ApplicationServices CoreServices;
  };
in
stdenv.mkDerivation rec {
  name = "mruby-zest";
  version = "HEAD";

  src = fetchFromGitHub {
    owner = "mruby-zest";
    repo = "mruby-zest-build";
    rev = "4eb88250f22ee684acac95d4d1f114df504e37a7";
    sha256 = "0j26y597l4g4dfqqyrjw0aw95v9sa42xd3rqwd1iwqlxy7vfgp2f";
    fetchSubmodules = true;
  };

  buildInputs = [
    bison
    libuv-static
    python2
    rake
    ruby
    # wget
  ] ++
  stdenv.lib.optionals
    stdenv.isDarwin
    (with darwin.apple_sdk.frameworks; [
      Cocoa
    ]);

  buildPhase = (
    if stdenv.isDarwin then ''
      $CC \
        -D STBTT_STATIC \
        -o deps/nanovg/src/nanovg.o \
        -c deps/nanovg/src/nanovg.c -fPIC

      ar -rc deps/libnanovg.a deps/nanovg/src/*.o

      (
        cd deps/pugl
        ./waf configure --no-cairo --static
        ./waf
      )

      make -C src/osc-bridge lib

      cp ${libuv-static}/lib/libuv.a ./deps

      (
        cd mruby
        BUILD_MODE="release" OS=Mac MRUBY_CONFIG=../build_config.rb rake clean all
      )

      $CC -shared -pthread \
        -o libzest.dylib \
        "$(find mruby/build/host -type f | grep -e "\.o$$" | grep -v bin)" ./deps/libnanovg.a \
        deps/libnanovg.a \
        src/osc-bridge/libosc-bridge.a \
        ${libuv-static}/lib/libuv.a

      $CC \
        -I deps/pugl \
        -std=gnu99 \
        -o zyn-fusion \
        test-libversion.c \
        deps/pugl/build/libpugl-0.a \
        -framework Cocoa -framework openGL
    '' else ''
      # Project README suggests to run "make setup" which downloads this with
      # wget. Build scripts expect to find it in two places.
      mkdir -p ./deps/libuv-v1.9.1/.libs
      cp ${libuv-static}/lib/libuv.a ./deps/libuv-v1.9.1/.libs
      cp -R ${libuv-static}/include ./deps/libuv-v1.9.1/include
      cp ${libuv-static}/lib/libuv.a ./deps

      make
    ''
  );

  installPhase = (
    if stdenv.isDarwin then ''
      ls -lha

      mkdir -p $out/bin
      cp zyn-fusion $out/bin

      mkdir -p $out/lib/libzest
      cp libzest.dylib $out/bin
    '' else ''
      mkdir -p $out/bin
      cp zest $out/bin

      mkdir -p $out/lib/libzest
      cp libzest.so $out/bin
    ''
  );

  meta = with stdenv.lib; {
    description = "Zyn-Fusion User Interface library";
    homepage = https://github.com/mruby-zest/mruby-zest-build;
    maintainers = with maintainers; [ eqyiel ];
    platforms = platforms.unix;
  };
}
