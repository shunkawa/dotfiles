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
    firefox-unwrapped = pkgs.firefox-unwrapped.override {
      # Default is to not use GTK3, which means that we won't get
      # gtk-key-theme.  Which means no Emacs keys.
      enableGTK3 = true;
      enableOfficialBranding = true;
    };
    chromium = pkgs.chromium.override {
      # At the moment only versions 56.0.0.0 and greater build with GTK3.
      # Channel 'dev' is on 56.0.2906.0, so use that.
      channel = "dev";
      pulseSupport = true;
      gnomeSupport = true;
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

        nodejs-6_x
        python35
        zsh
        nix-zsh-completions
        openssh
        owncloudclient
        # seafile-client

        # audio
        jack2Full
        qjackctl
        ardour
        a2jmidid
        qsampler
        seq24
        yoshimi

        # fonts
        dejavu_fonts
        font-droid
        liberation_ttf
        opensans-ttf
        noto-fonts-cjk
        noto-fonts-emoji
        noto-fonts

        # command line utilities
        file
        direnv
        bind
        stow
        tmux
        notmuch
        pwgen
        silver-searcher
        haskellPackages.ShellCheck
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
        imagemagick
        isync
        nmap
        xorg.xkbcomp
        xorg.xev
        xorg.xmodmap
        xorg.xdpyinfo
      ];
    });
  };
}
