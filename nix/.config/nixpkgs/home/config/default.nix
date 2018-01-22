{ pkgs, lib, ... }:

{
  imports = [
    ./tmux
    ./zsh
    ./xkb
    ./spectacle
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
    ] ++ (with local-packages; [
      emacs-with-packages
      tern
      nixfmt
    ]) ++ lib.optionals stdenv.isLinux ([
      firefox
      wine
      winetricks
      chromium
      gimp
      mpv
      icedtea8_web # iDRAC administration
      libreoffice
      steam
      wine
      gimp
      anki
      youtube-dl
      desmume
    ] ++ (with local-packages; [riot])) ++ lib.optionals stdenv.isDarwin ([
      (youtube-dl.override({ phantomjsSupport = false; }))
      (mpv.override ({
        vaapiSupport = false;
        xvSupport = false;
        youtube-dl = youtube-dl.override ({
          phantomjsSupport = false;
        });
      }))
    ]);
  };
}
