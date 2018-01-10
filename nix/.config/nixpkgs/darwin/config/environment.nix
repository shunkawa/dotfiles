{ config, lib, pkgs, ... }:

{
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
      msmtp
      mu
      nix-prefetch-scripts
      nix-repl
      nixops
      openssh
      pass
      pwgen
      rsync
      sift
      silver-searcher
      socat
      stow
      tree
      unrar
      unzip
      wget
      which
      ripgrep
      fd

      syncthing
      iterm2

      local-packages.react-devtools

      postgresql
      # apacheHttpd
      # awsebcli
      flow
      jekyll
      lftp
      # local-packages.fontcustom
      local-packages.nodePackages."@jasondibenedetto/plop"
      local-packages.nodePackages.imapnotify
      local-packages.nodePackages.react-native-cli
      local-packages.nodePackages.tern
      local-packages.nodePackages.wscat
      local-packages.nodePackages.yarn
      local-packages.scss-lint
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
