{ pkgs, lib, ... }:

{
  imports = [
    ./tmux
    ./zsh
    ./xkb
    ./syncthing
    ./mbsync
  ];

  programs.home-manager.enable = true;
  programs.home-manager.path = "<home-manager>";

  xdg.enable = true;

  home = {
    file.".psqlrc".source = pkgs.writeText "psqlrc" ''
      \x auto
    '';

    packages = with pkgs; [
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
      nextcloud-client
      # python27Packages.syncthing-gtk
      libreoffice
      steam
      wine
      emacs
    ] ++ (with local-packages; [
      # emacs-git # broken :(
      nixfmt
      riot
    ]);
  };
}
