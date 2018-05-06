#!/bin/sh

# shellcheck source=../../prefetch.sh
. "$(dirname "${0}")/../../prefetch.sh"

cat <<EOF | "${JQ}" -s add >| "$(dirname "${0}")/tmux-packages.json"
  $(prefetch_git https://github.com/seebi/tmux-colors-solarized.git tmux-colors-solarized)
  $(prefetch_git https://github.com/tmux-plugins/tmux-copycat.git tmux-copycat)
  $(prefetch_git https://github.com/tmux-plugins/tmux-fpp.git tmux-fpp)
  $(prefetch_git https://github.com/tmux-plugins/tmux-open.git tmux-open)
  $(prefetch_git https://github.com/tmux-plugins/tmux-pain-control.git tmux-pain-control)
  $(prefetch_git https://github.com/tmux-plugins/tmux-sensible.git tmux-sensible)
  $(prefetch_git https://github.com/tmux-plugins/tmux-yank.git tmux-yank)
EOF
