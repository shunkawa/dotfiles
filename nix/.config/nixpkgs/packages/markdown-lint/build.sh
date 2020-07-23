#!/usr/bin/env bash

set -eu

WORKING_DIR="$(cd "$(dirname "${0}")" >/dev/null 2>&1; pwd -P)"

rm -f "${WORKING_DIR}/composition.nix" "${WORKING_DIR}/node-env.nix" "${WORKING_DIR}/node-packages.nix"

node2nix \
  --composition "${WORKING_DIR}/composition.nix" \
  --input "${WORKING_DIR}/node-packages.json" \
  --lock "${WORKING_DIR}/package-lock.json" \
  --node-env "${WORKING_DIR}/node-env.nix"
