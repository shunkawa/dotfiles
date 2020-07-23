#!/bin/sh

# shellcheck source=../prefetch.sh
. "$(dirname "${0}")/../prefetch.sh"

cat <<EOF | "${JQ}" -s add >| "$(dirname "${0}")/zsh-packages.json"
  $(prefetch_git https://github.com/sindresorhus/pure.git pure)
EOF
