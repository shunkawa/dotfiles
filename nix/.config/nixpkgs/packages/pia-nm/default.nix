{ stdenv }:

stdenv.mkDerivation rec {
  name = "pia-nm";

  src = ./etc;

  dontConfigure = true;

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/etc
    cp -r $src/NetworkManager $out/etc/NetworkManager
    cp -r $src/openvpn $out/etc/openvpn
  '';
}
