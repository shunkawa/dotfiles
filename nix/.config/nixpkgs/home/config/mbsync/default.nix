{ pkgs, lib, ... }:

{
  home.file.".mbsyncrc".source = ./mbsyncrc;
}
