#!/bin/sh

set -eu

export GOPATH="$(pwd)"

PACKAGE="$(dirname 0)/src/github.com/kazegusuri/grpcurl"

nix run nixpkgs.dep2nix --command dep2nix -i "${PACKAGE}/Gopkg.lock" -o deps.nix

exit 0
