{ config, lib, pkgs, ... }:

let

  localPackages = (import ../../pkgs/all-packages.nix) {
    inherit config lib pkgs;
  };

  # Pin to a specific version of nixpkgs like this:
  # nixpkgsMaster = import ((import <nixpkgs> { }).fetchFromGitHub {
  #   owner = "NixOS";
  #   repo = "nixpkgs";
  #   rev = "fd22d671ecad983fbbbd92c4626204f09c9af8ff";
  #   sha256 = "0pn8w5v2b7c82nr0zbb91bfzylr97hq3knwhlc8xhzibhp0d723a";
  # }) { config = { }; };
  # then, for example: nixpkgsMaster.pkgs.nodejs-8_x

in {
  environment = {
    systemPackages = with pkgs; [
      aspell
      aspellDicts.en
      bind
      coreutils
      curl
      direnv
      # ffmpeg # broken due to issue with LAME
      file
      findutils
      fzf
      gitAndTools.git-crypt
      gitAndTools.gitFull
      gnumake
      gnupg
      gnused
      gnutar
      haskellPackages.ShellCheck
      htop
      isync
      localPackages.emacs-git
      localPackages.nodePackages.reddit-oauth-helper
      msmtp
      mu
      nix-prefetch-scripts
      nix-repl
      nixops
      openssh
      pass
      pwgen
      reattach-to-user-namespace
      rsync
      sift
      silver-searcher
      socat
      stow
      syncthing
      tmux
      tree
      unrar
      unzip
      wget
      which
      ripgrep
      fd

      localPackages.react-devtools

      (mpv.override ({
        # x11Support = false;
        # xineramaSupport = false;
        vaapiSupport = false;
        # sdl2Support = false;
        xvSupport = false;
      }))

      postgresql
      # apacheHttpd
      # awsebcli
      flow
      jekyll
      lftp
      # localPackages.fontcustom
      localPackages.nodePackages."@jasondibenedetto/plop"
      localPackages.nodePackages.imapnotify
      localPackages.nodePackages.react-native-cli
      localPackages.nodePackages.tern
      localPackages.nodePackages.wscat
      localPackages.nodePackages.yarn
      localPackages.scss-lint
      nodePackages_6_x.node2nix
      nodejs-8_x
      # php
      # phpPackages.composer
      watchman
    ];

    variables = {
      # If you don't do this, Emacs will throw errors like this because it can't
      # find the dictionary files:
      # Starting new Ispell process /run/current-system/sw/bin/aspell with english dictionary...
      # Error enabling Flyspell mode:
      # (Error: The file "/nix/store/ ... /lib/aspell/english" can not be opened for reading.)
      ASPELL_CONF = "data-dir /run/current-system/sw/lib/aspell";
    };

    shellAliases = {
      emacs = "${localPackages.emacs-git}/Applications/Emacs.app/Contents/MacOS/Emacs";
    };

    pathsToLink = [
      "/lib"           # necessary for ... something
      "/share/emacs"   # Necessary for emacs support files (mu4e)
    ];

    etc = {
      "ssl/certs/ca-certificates.crt".source =
        "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";

      # github.com/facebook/react-native/issues/9309#issuecomment-238966924
      "sysctl.conf" = {
        text = ''
          kern.maxfiles=10485760
          kern.maxfilesperproc=1048576
        '';
      };
    };
  };
}
