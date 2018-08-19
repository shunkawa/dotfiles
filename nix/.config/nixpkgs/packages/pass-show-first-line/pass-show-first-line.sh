#!/bin/sh

if (command -v pass >/dev/null 2>&1); then
  pass show "$@" | head -n 1
else
  echo '** ERROR:' "pass not found in \$PATH" >&2
  return 1;
fi
