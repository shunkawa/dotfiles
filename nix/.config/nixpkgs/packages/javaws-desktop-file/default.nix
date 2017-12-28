{ stdenv, icedtea }:

stdenv.mkDerivation rec {
  name = "javaws-desktop-file";

  unpackPhase = "true"; # don't unpack

  dontBuild = true;

  dontConfigure = true;

  installPhase = ''
    mkdir -p $out/share/applications
    cat > $out/share/applications/javaws.desktop <<EOF
    [Desktop Entry]
    Name=Java Web Start
    Comment=Java Web Start
    Exec=${icedtea}/bin/javaws
    Terminal=false
    Type=Application
    Icon=javaws
    Categories=Application;Network
    MimeType=application/x-java-jnlp-file;
    EOF
  '';
}
