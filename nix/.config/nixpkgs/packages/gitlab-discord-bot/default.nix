{ pkgs }:

((import ./node { inherit pkgs; }).gitlab-discord-bot.override {
  postInstall = ''
    cp $out/lib/node_modules/gitlab-discord-bot/config.example.js \
      $out/lib/node_modules/gitlab-discord-bot/config.js
  '';
})
