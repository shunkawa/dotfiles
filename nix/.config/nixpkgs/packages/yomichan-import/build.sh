#!/bin/sh

set -eu

nix-shell --command 'cd yomichan-import; vgo2nix'
mv yomichan-import/deps.nix .
