{ stdenv
, fetchurl
, gnome3
, pkgconfig
, python
, pythonPackages
, writeText
}:

stdenv.mkDerivation rec {
  pkgname = "nautilus-python";
  name = "${pkgname}-${version}";
  version = "1.1";
  src = fetchurl {
    url = "https://download.gnome.org/sources/${pkgname}/${version}/${name}.tar.xz";
    sha256 = "0ss91k14jlwqyc5n1h6ppzbzmjgsvi242z8fkn11y4wfva5f09bq";
  };

  buildInputs = [
    pkgconfig
    python
    pythonPackages.pygobject3
    gnome3.nautilus # libnautilus-extension
    gnome3.gtk
  ];

  patches = [ ./extension-dir.patch ];

  patchFlags = "--strip 1 --ignore-whitespace --unified";

  # preConfigure = ''
  #   patch \
  #     --strip 1 \
  #     --ignore-whitespace \
  #     --unified < ${./fix-nautilus-python-datadir.patch}
  # '';
  # configurePhase = "./configure --prefix=/run/current-system/sw";

  # dontAddPrefix = true;

  # configureFlags = [ "--prefix=" ];

  # prefix = "/run/current-system/sw/share";

  # patchPhase = ''
  #    patch --strip 1 --ignore-whitespace --unified < ${./fix-nautilus-python-datadir.patch}
  # '';

  # dontPatchEFL = true;

  # dontPatchShebangs = true;

  # installFlags = ["datadir=/run/current-system/sw/share"];

  # preBuild = ''
  #   ls -lha
  #   sed -i s%libdir=\'${gnome3.nautilus}%/run/current-system/sw% src/libnautilus-python.la
  # '';

  installPhase = ''
    # sed -i s%libdir=\'${gnome3.nautilus}%/run/current-system/sw% src/libnautilus-python.la
    # make install
    mkdir -p $out/lib/nautilus/extensions-3.0
    install -c src/.libs/libnautilus-python.so $out/lib/nautilus/extensions-3.0
    # mkdir $out/kek
    # mv * $out/kek
  '';

# Nautilus is finding this extension:
# open("/nix/store/j7z30fg9harsr7c5sjh5fs8rqj5f2dgv-system-path/lib/nautilus/extensions-3.0/libnautilus-python.so", O_RDONLY|O_CLOEXEC) = 12
# how are # But not looking in /run/current-system/sw for /run/current-system/sw/share/nautilus-python/extensions/syncstate.py
# open("/nix/store/5y182v03vgahackh33m1s1x4b27d4c6z-python-2.7.13/lib/libpython2.7.so.1.0", O_RDONLY|O_CLOEXEC) = 12
# read(12, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\240\356\3\0\0\0\0\0"..., 832) = 832
# fstat(12, {st_mode=S_IFREG|0555, st_size=2045752, ...}) = 0
# mmap(NULL, 4062536, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 12, 0) = 0x7f1500f7f000
# mprotect(0x7f15010ff000, 2093056, PROT_NONE) = 0
# mmap(0x7f15012fe000, 262144, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 12, 0x17f000) = 0x7f15012fe000
# mmap(0x7f150133e000, 134472, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7f150133e000
# close(12)                               = 0
# mprotect(0x7f15012fe000, 16384, PROT_READ) = 0
# mprotect(0x7f1501565000, 4096, PROT_READ) = 0
# open("/nix/store/dny00kby0ncls5z49bcd3x81i62k97ji-nautilus-python-1.1/share/nautilus-python/extensions", O_RDONLY|O_NONBLOCK|O_DIRECTORY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
# open("/home/eqyiel/.local/share/nautilus-python/extensions", O_RDONLY|O_NONBLOCK|O_DIRECTORY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
# munmap(0x7f150135f000, 2125952)         = 0
# munmap(0x7f1500f7f000, 4062536)         = 0
#
# is that .so somehow aware of its location?
}
