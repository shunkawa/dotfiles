{ stdenv
, Cocoa
, OpenGL
, bison
, cairo
, callPackage
, darwin
, fetchFromGitHub
, libpugl-static
, libuv-static
, python2
, rake
, ruby
, wget
}:
stdenv.mkDerivation rec {
  name = "mruby-zest";
  version = "HEAD";

  src = fetchFromGitHub (import ./mruby-zest-src.nix);

  buildInputs = [
    Cocoa
    OpenGL
    bison
    libpugl-static
    libuv-static
    rake
    ruby
  ];

  patches = [ ./use-dylib.patch ];

  NIX_LDFLAGS = "-headerpad_max_install_names";
  NIX_CFLAGS_COMPILE = "-fvisibility=hidden -fdata-sections -ffunction-sections";

  buildPhase = ''
    ruby ./rebuild-fcache.rb

    $CC \
      -D STBTT_STATIC \
      -o deps/nanovg/src/nanovg.o \
      -c deps/nanovg/src/nanovg.c -fPIC

    ar -rc deps/libnanovg.a deps/nanovg/src/*.o

    make -C src/osc-bridge lib

    sed -i 's%linker.*deps/pugl/build/libpugl-0\.a.*$%linker.flags_after_libraries  << "${"${libpugl-static}/lib/libpugl-0.a"}"%g' build_config.rb
    sed -i 's%linker.*\.\./deps/libuv.a.*$%linker.flags_after_libraries  << "${"${libuv-static}/lib/libuv.a"}"%g' build_config.rb

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
      ${libpugl-static}/lib/libpugl-0.a \
      -framework Cocoa -framework OpenGL
  '';

  installPhase = ''
    mkdir -p $out/opt/zyn-fusion
    mkdir -p $out/opt/zyn-fusion/osc-bridge/schema
    mkdir -p $out/opt/zyn-fusion/{schema,qml,font,completions}
    cp -v src/mruby-zest/qml/*             $out/opt/zyn-fusion/qml
    cp -v src/mruby-zest/example/*         $out/opt/zyn-fusion/qml
    cp -v src/osc-bridge/schema/test.json  $out/opt/zyn-fusion/schema
    cp -v deps/nanovg/example/*.ttf        $out/opt/zyn-fusion/font
    cp -v mruby/bin/mruby                  $out/opt/zyn-fusion
    cp -v libzest.dylib                    $out/opt/zyn-fusion
    # Note: this cannot actually be executed on macOS because it searches for
    # "zest.so" in PATH.  ZynAddSubFX deliberately ships without a "standalone"
    # application on macOS:
    # https://sourceforge.net/p/zynaddsubfx/mailman/message/36272025/
    cp -v zyn-fusion                       $out/opt/zyn-fusion
  '';

  meta = with stdenv.lib; {
    description = "Zyn-Fusion User Interface library";
    homepage = https://github.com/mruby-zest/mruby-zest-build;
    maintainers = with maintainers; [ eqyiel ];
    platforms = platforms.darwin;
  };
}
