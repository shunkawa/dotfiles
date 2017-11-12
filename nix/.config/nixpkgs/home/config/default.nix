{ pkgs, lib, ... }:

{
  imports = [
    ./tmux
    ./zsh
  ];

  programs.home-manager.enable = true;
  programs.home-manager.path = "<home-manager>";

  home.packages = with pkgs; [
    fd
    fortune
    gitAndTools.git-crypt
    gitAndTools.gitFull
    haskellPackages.ShellCheck
    isync
    jhead
    jq
    ncmpcpp
    pass
    pinentry
    speedtest-cli
  ] ++ lib.optionals stdenv.isLinux [ 
    firefox
    chromium
    gimp
    mpv
    icedtea8_web # iDRAC administration
    python27Packages.syncthing-gtk
    libreoffice 
    steam
    wine
  ] ++ (with local-packages; [
    emacs-git
    purs
    nixfmt
    riot
  ]);
}
