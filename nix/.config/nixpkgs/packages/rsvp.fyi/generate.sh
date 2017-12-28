#!/bin/sh -e

# I used node2nix 1.1.1 (commit 6545937592e7e54a14a2df315598570480fee9f).
# For any packages that are installed from local copies (see rsvp.fyi), you'll
# need to go and edit the attribute name in ./node-packages.nix after generating
# unless you want to have package names like "rsvp.fyi-server-undefined".

rm -f composition.nix node-packages.nix
node2nix \
    -5 \
    -i package.json \
    -c composition.nix \
    --supplement-input supplement.json \
    -e ../node-packages/node-env.nix
