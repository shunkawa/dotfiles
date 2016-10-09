# ~/.nixpkgs/config.nix

{ pkgs }:
let
  inherit (pkgs) lib buildEnv;
  homeDir = builtins.getEnv "HOME";
in
{
  allowUnfree = true;
  packageOverrides = pkgs: rec {
    pass = pkgs.pass.override {
      gnupg = pkgs.gnupg21;
    };
    rkm = lib.lowPrio (buildEnv {
      name = "rkm";
      ignoreCollisions = true;
      paths = with pkgs; [        
        wine
        emacs
        firefox
        chromium
        mpd
        mpdris2
        ncmpcpp
        mpv

        nodejs-5_x
        python35
        zsh
        nix-zsh-completions
        openssh
        owncloudclient
        # seafile-client

        # fonts
        dejavu_fonts
        font-droid
        liberation_ttf
        opensans-ttf
        noto-fonts-cjk
        noto-fonts-emoji
        noto-fonts

        # command line utilities
        stow
        tmux
        notmuch
        pwgen
        silver-searcher
        haskellPackages.ShellCheck
        tmux
        tree
        xsel
        rsync
        which
        coreutils
        findutils
        gnugrep
        gnupg21
        pinentry
        ncdu
        pass
        gitAndTools.gitFull
        gitAndTools.git-crypt
        whois
        inetutils
        isync
        nmap
        xorg.xkbcomp
        xorg.xev
        xorg.xmodmap
      ];
    });
  };
}
