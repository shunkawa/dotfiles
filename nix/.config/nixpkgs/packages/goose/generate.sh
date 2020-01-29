#!/bin/sh

set -eu

export GOPATH="$(pwd)"

PACKAGE="$(dirname 0)/src/github.com/pressly/goose"

trap 'cleanup' EXIT

cleanup() {
  cd "${PACKAGE}"; git clean -fd
}

(cd "${PACKAGE}"; nix run nixpkgs.dep --command dep ensure -v)
nix run nixpkgs.dep2nix --command dep2nix -i "${PACKAGE}/Gopkg.lock" -o deps.nix

exit 0
