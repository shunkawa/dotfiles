{ stdenv, coreutils, curl, fetchurl, makeWrapper }:

# https://www.privateinternetaccess.com/forum/discussion/23431

stdenv.mkDerivation rec {
  name = "get-pia-port-forwarding-assignment";

  unpackPhase = "true"; # nothing to unpack

  src = fetchurl {
    url = "https://privateinternetaccess.com/installer/port_forwarding.sh";
    sha256 = "0f4dsdfm5cr8jgpqfsqxx1a1v31c0vivkl9xhgnyvcxxzwjvxnwj";
  };

  dontConfigure = true;

  buildInputs = [ makeWrapper ];

  dontBuild = true;

  installPhase = ''
    install -D -m755 $src $out/bin/get-pia-port-forwarding-assignment
    wrapProgram $out/bin/get-pia-port-forwarding-assignment \
      --prefix PATH : ${coreutils}/bin \
      --prefix PATH : ${curl}/bin
  '';
}
