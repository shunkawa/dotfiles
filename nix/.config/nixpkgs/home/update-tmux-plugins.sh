#!/bin/sh

NIX_PREFETCH_GIT="$(nix-build '<nixpkgs>' -A nix-prefetch-git --no-out-link)/bin/nix-prefetch-git"
JQ="$(nix-build '<nixpkgs>' -A jq --no-out-link)/bin/jq"

fetch_plugin () {
  eval "${NIX_PREFETCH_GIT} ${1} --rev HEAD | ${JQ} \"{ \\\"${2}\\\": . }\""
}

cat <<EOF | "${JQ}" -s add >| tmux-plugins.json
  $(fetch_plugin git@github.com:tmux-plugins/tmux-yank.git tmux-yank)
  $(fetch_plugin git@github.com:tmux-plugins/tmux-copycat.git tmux-copycat)
EOF
