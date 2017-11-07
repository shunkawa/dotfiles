#!/bin/sh

export NIX_PREFETCH_GIT="$(nix-build '<nixpkgs>' -A nix-prefetch-git --no-out-link)/bin/nix-prefetch-git"
export JQ="$(nix-build '<nixpkgs>' -A jq --no-out-link)/bin/jq"

prefetch_git () {
  eval "${NIX_PREFETCH_GIT} ${1} --rev HEAD | ${JQ} \"{ \\\"${2}\\\": . }\""
}

# Usage:
#
# . prefetch.sh
#
# cat <<EOF | "${JQ}" -s add >| bleeding-edge-packages.json
#   $(prefetch_git git://git.sv.gnu.org/emacs.git emacs-git)
# EOF
