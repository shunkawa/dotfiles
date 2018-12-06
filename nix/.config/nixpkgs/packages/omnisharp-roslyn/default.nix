{ stdenv, autoPatchelfHook, fetchurl, writeScriptBin, zlib }:

let
  omnisharp-linux = stdenv.mkDerivation rec {
    name = "omnisharp-linux";
    version = "1.32.8";

    src = fetchurl {
      url = "https://github.com/OmniSharp/omnisharp-roslyn/releases/download/v${version}/${name}-x64.tar.gz";
      sha256 = "007k88ms97k8r152x805gylz7g7mmgcz7x67w2pb0dgdp8hk43md";
    };

    dontConfigure = true;

    # https://github.com/NixOS/nixpkgs/issues/47374#issuecomment-428282730
    LD_LIBRARY_PATH="${stdenv.cc.cc.lib}/lib64:$LD_LIBRARY_PATH";

    buildInputs = [ autoPatchelfHook zlib ];

    sourceRoot = ".";

    unpackPhase = ''
      mkdir "${name}"
      tar -xvf "$src" -C "${name}"
    '';

    patchPhase = ''
      # Don't try to chmod files in the nix store
      sed -i '/chmod 755 ''${mono_cmd}/,+1d' ${name}/run
    '';

    installPhase = ''
      cp -r "${name}" "$out"
    '';
  };
in writeScriptBin "omnisharp-roslyn" ''
  #!${stdenv.shell}
  exec ${omnisharp-linux}/run "$@"
''
