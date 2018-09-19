#!/bin/sh -e

rm -f default.nix node-packages.nix node-env.nix
nix run -f ./node2nix.nix -c node2nix \
  --development \
  --nodejs-10 \
  --input node-packages.json \
  --composition default.nix \
  --node-env node-env.nix

# Make the attribute name "gitlab-discord-bot" rather than
# "gitlab-discord-bot-https://github.com/jellysquid3/gitlab-discord-bot/archive/commit-sha1.tar.gz"
sed -i "s%gitlab-discord-bot-$(jq '.[0]["gitlab-discord-bot"]' --raw-output < node-packages.json)%gitlab-discord-bot%g" node-packages.nix
