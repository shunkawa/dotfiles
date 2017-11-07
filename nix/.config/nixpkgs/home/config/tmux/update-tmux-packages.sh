#!/bin/sh

. ../../prefetch.sh

cat <<EOF | "${JQ}" -s add >| tmux-packages.json
  $(prefetch_git https://github.com/tmux-plugins/tmux-yank.git tmux-yank)
  $(prefetch_git https://github.com/tmux-plugins/tmux-copycat.git tmux-copycat)
  $(prefetch_git https://github.com/tmux-plugins/tmux-sensible.git tmux-sensible)
  $(prefetch_git https://github.com/tmux-plugins/tmux-fpp.git tmux-fpp)
  $(prefetch_git https://github.com/tmux-plugins/tmux-pain-control.git tmux-pain-control)
  $(prefetch_git https://github.com/tmux-plugins/tmux-open.git tmux-open)
EOF
