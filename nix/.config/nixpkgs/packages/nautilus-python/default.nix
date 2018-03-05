# TODO:
# This package needs an env variable like this:
# https://github.com/NixOS/nixpkgs/blob/618ac29687a650d854c8bea7efd4490387589ce2/nixos/modules/services/x11/desktop-managers/gnome3.nix#L159
# I suggest NAUTILUS_PYTHON_EXTENSION_DIR, see the patch

{ stdenv
, fetchurl
, gnome3
, pkgconfig
, python
, pythonPackages
, writeText
}:

stdenv.mkDerivation rec {
  pname = "nautilus-python";
  name = "${pname}-${version}";
  version = "1.2";
  src = fetchurl {
    url = "https://download.gnome.org/sources/${pname}/${version}/${name}.tar.xz";
    sha256 = "17nl0m6dz5lv41l5bl5ff298na90vmrvaxb3zpidhyjjiz001q56";
  };

  patches = [ ./extension-dir.patch ];

  buildInputs = [
    pkgconfig
    python
    pythonPackages.pygobject3
    gnome3.nautilus # libnautilus-extension
    gnome3.gtk
  ];

  configureFlags = ["--prefix=$out"];

  patchFlags = "--strip 1 --ignore-whitespace --unified";

  installPhase = ''
    mkdir -p $out/lib/nautilus/extensions-3.0
    install -c src/.libs/libnautilus-python.so $out/lib/nautilus/extensions-3.0
  '';
}
