{ stdenv, postgresql, makeWrapper }:

stdenv.mkDerivation {
  name = "nuke-room-from-synapse";

  unpackPhase = "true"; # don't unpack

  buildInputs = [ makeWrapper ];

  dontBuild = true;

  dontConfigure = true;

  installPhase = ''
    mkdir -p $out/bin
    cp ${./nuke-room-from-synapse.sh} $out/bin/nuke-room-from-synapse
    chmod +x $out/bin/nuke-room-from-synapse
    wrapProgram $out/bin/nuke-room-from-synapse \
      --prefix PATH ":" ${postgresql}/bin
  '';
}
