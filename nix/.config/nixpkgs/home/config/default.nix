{ pkgs, ... }:

{
  imports = [ ./tmux ];

  programs.home-manager.enable = true;
  programs.home-manager.path = "<home-manager>";

  home.packages = [
    pkgs.fortune
    pkgs.local-packages.emacs-git
    pkgs.local-packages.purs
  ];
}
