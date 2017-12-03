{ pkgs, lib, ... }:

{
  imports = [
    ./tmux
    ./zsh
    ./xkb
  ];

  programs.home-manager.enable = true;
  programs.home-manager.path = "<home-manager>";

  home.file.".psqlrc".source = pkgs.writeText "psqlrc" ''
    \x auto
  '';

  xdg.enable = true;

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
    firefox-bin
    wine
    winetricks
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
    nixfmt
    riot
  ]);
}
