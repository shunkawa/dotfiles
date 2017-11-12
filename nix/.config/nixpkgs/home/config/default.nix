{ pkgs, lib, ... }:

{
  imports = [
    ./tmux
    ./zsh
  ];

  programs.home-manager.enable = true;
  programs.home-manager.path = "<home-manager>";

  home.packages = with pkgs; [
    chromium
    fd
    firefox
    fortune
    gimp
    gitAndTools.git-crypt
    gitAndTools.gitFull
    haskellPackages.ShellCheck
    icedtea8_web # iDRAC administration
    isync
    jhead
    jq
    libreoffice
    mpv
    ncmpcpp
    pass
    pinentry
    python27Packages.syncthing-gtk
    speedtest-cli
    steam
    wine
  ] ++ (with local-packages; [
    emacs-git
    purs
    nixfmt
    riot
  ]);
}
