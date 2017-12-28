{ stdenv, gnused, nettools, runCommand }:

runCommand "get-hostname" {
  buildInputs = [ gnused ] ++ stdenv.lib.optional stdenv.isLinux [ nettools ];
} ''echo "$(hostname)" | sed 's#\(.*\)#"\1"#' > $out''
