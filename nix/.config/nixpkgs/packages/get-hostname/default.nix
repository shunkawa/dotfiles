{ stdenv, gnused, nettools, runCommand }:

runCommand "get-hostname" {
  buildInputs = [ gnused nettools ];
} ''echo "$(hostname)" | sed 's#\(.*\)#"\1"#' > $out''
