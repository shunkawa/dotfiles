#!/bin/sh

if (command -v xdg-open >/dev/null 2>&1); then
  # https://github.com/NixOS/nixpkgs/issues/25556#issuecomment-356116362
  XDG_CURRENT_DESKTOP="X-Generic" xdg-open "${@}"
else
  /usr/bin/open "${@}"
fi
