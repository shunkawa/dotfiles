{ pkgs, lib, ... }:

{
  home.file.".mbsyncrc".source = import ../../../../../../mbsync/.mbsyncrc;
}
