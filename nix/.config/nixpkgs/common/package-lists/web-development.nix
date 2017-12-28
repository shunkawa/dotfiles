{ pkgs, localPackages, ...}:

with pkgs; [
  hugo
  jekyll
  lftp
  localPackages.nodePackages."@jasondibenedetto/plop"
  localPackages.nodePackages.eslint-cli
  localPackages.nodePackages.grunt-cli
  localPackages.nodePackages.imapnotify
  localPackages.nodePackages.tern
  localPackages.nodePackages.wscat
  localPackages.nodePackages.yarn
  localPackages.scss-lint
  nodePackages_6_x.node2nix
  nodejs-8_x
  php
  php71Packages.composer
  php71Packages.phpcs
  php71Packages.phpcbf

  # For packaging ruby stuff
  bundix
  bundler
]
