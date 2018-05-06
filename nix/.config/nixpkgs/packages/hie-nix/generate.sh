#!/bin/sh

# shellcheck source=../../home/prefetch.sh
. "$(dirname "${0}")/../../home/prefetch.sh"

cat <<EOF | "${JQ}" -s add >| "$(dirname "${0}")/packages.json"
  $(prefetch_git https://github.com/domenkozar/hie-nix hie-nix)
EOF
