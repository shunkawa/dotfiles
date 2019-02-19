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

  manual.manpages.enable = false;

  home = {
    file.".psqlrc".source = pkgs.writeText "psqlrc" ''
      \x auto
    '';

    packages = with pkgs; [
      aspell
      aspellDicts.en
      bat
      bind
      coreutils
      curl
      direnv
      fd
      file
      findutils
      fortune
      fzf
      git-lfs
      gitAndTools.git-crypt
      gitAndTools.gitFull
      gitAndTools.transcrypt
      gnumake
      gnupg
      gnused
      gnutar
      htop
      isync
      jhead
      jq
      msmtp
      mu
      ncmpcpp
      nix-prefetch-scripts
      nixops
      openssh
      openssl
      pass
      pinentry
      procmail # formail used for some mu hacks
      pwgen
      ripgrep
      rsync
      sift
      silver-searcher
      socat
      speedtest-cli
      stow
      tree
      unrar
      unzip
      wget
      which
    ] ++ (with local-packages; [
      docker-convenience-scripts
      emacs-with-packages
      hiptext
      pass-show-first-line
    ]) ++ lib.optionals stdenv.isLinux ([
        anki
        chromium
        desmume
        discord
        firefox
        gimp
        gimp
        icedtea8_web # iDRAC administration
        libreoffice
        mpv
        shellcheck # ghc isn't available from any cache on darwin
        steam
        vdirsyncer
        youtube-dl
      ]
      ++ (with pkgs.ibus-engines; [ local-packages.ibus-engines.mozc uniemoji ])
      ++ (with local-packages; [open riot]))
    ++ lib.optionals stdenv.isDarwin ([
      (youtube-dl.override ({ phantomjsSupport = false; }))
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
