{ pkgs, lib, ... }:

with lib;

mkIf pkgs.stdenv.isDarwin {
  home.file."Library/Application Support/Spectacle/Shortcuts.json".source = ./Shortcuts.json;
}
