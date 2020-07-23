#!/bin/sh

set -eu

# shellcheck source=../prefetch.sh
. "$(dirname "${0}")/../prefetch.sh"

cat <<EOF | "${JQ}" -s add >| "$(dirname "${0}")/versions.json"
  $(prefetch_git git://git.sv.gnu.org/emacs.git emacs)
EOF
