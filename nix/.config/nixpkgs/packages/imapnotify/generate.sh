#!/bin/sh -e

rm -f node-packages.nix node-env.nix
node2nix -6 -i package.json -c default.nix -e node-env.nix
sed -i s%imapnotify-git+https://github.com/a-sk/node-imapnotify%imapnotify% \
    ./node-packages.nix
