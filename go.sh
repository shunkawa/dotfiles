#!/bin/bash

stow() {
  cd ~/.config/dotfiles/src
  for i in *; do stow -v $i -t ~/ -R; done
}

unstow() {
  cd ~/.config/dotfiles/src
  for i in *; do stow -v $i -t ~/ -D; done
}

adopt() {
  cd ~/.config/dotfiles/src
  for i in *; do stow -v $i -t ~/ --adopt; done
}

case $1 in
  stow|unstow|adopt)
    $1
    ;;
  *)
    echo "Usage: go (install | uninstall | adopt)"
esac
