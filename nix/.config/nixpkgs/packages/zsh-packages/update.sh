#!/bin/sh

set -eu

# shellcheck source=../prefetch.sh
. "$(dirname "${0}")/../prefetch.sh"

cat <<EOF | "${JQ}" -s add >| "$(dirname "${0}")/versions.json"
  $(prefetch_git https://github.com/sindresorhus/pure.git pure)
EOF
