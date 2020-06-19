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
    libuv
    python2
    rake
    ruby
    wget
  ] ++
  stdenv.lib.optionals
    stdenv.isDarwin
    (with darwin.apple_sdk.frameworks; [
      Cocoa
    ]);

  buildPhase = ''
    # Build expects this static lib in two places
    mkdir -p ./deps/libuv-v1.9.1/.libs
    cp ${libuv-static}/lib/libuv.a ./deps/libuv-v1.9.1/.libs
    cp -R ${libuv-static}/include ./deps/libuv-v1.9.1/include
    cp ${libuv-static}/lib/libuv.a ./deps
  '' + (
    if stdenv.isDarwin then ''
      OS=Mac make osx
    '' else ''
      make
    ''
  );

  installPhase = ''
    mkdir -p $out/bin
    cp zest $out/bin

    mkdir -p $out/lib/libzest
    cp libzest.so $out/bin
  '';

  meta = with stdenv.lib; {
    description = "Zyn-Fusion User Interface library";
    homepage = https://github.com/mruby-zest/mruby-zest-build;
    maintainers = with maintainers; [ eqyiel ];
    platforms = platforms.darwin;
  };
}
