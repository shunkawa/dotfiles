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
    # chromium = pkgs.chromium.override {
    #   # At the moment only versions 56.0.0.0 and greater build with GTK3.
    #   # Channel 'dev' is on 56.0.2906.0, so use that.
    #   channel = "dev";
    #   pulseSupport = true;
    #   gnomeSupport = true;
    # };

    rkm = lib.lowPrio (buildEnv {
      name = "rkm";
      ignoreCollisions = true;
      paths = with pkgs; [        
        a2jmidid
        ardour
        bind
        chromium
        coreutils
        dejavu_fonts
        direnv
        emacs
        ffmpeg
        file
        findutils
        firefox
        font-droid
        gitAndTools.git-crypt
        gitAndTools.gitFull
        gnugrep
        gnupg21
        haskellPackages.ShellCheck
        imagemagick
        inetutils
        isync
        jack2Full
        jhead
        libreoffice
        liberation_ttf
        mpd
        mpdris2
        mpv
        ncdu
        ncmpcpp
        nix-repl
        nix-zsh-completions
        nmap
        nodejs-7_x
        notmuch
        noto-fonts
        noto-fonts-cjk
        noto-fonts-emoji
        opensans-ttf
        openssh
        owncloudclient
        pass
        pinentry
        pwgen
        python35
        qjackctl
        qsampler
        rsync
        seq24
        silver-searcher
        steam
        stow
        tmux
        tree
        which
        whois
        wine
        xorg.xdpyinfo
        xorg.xev
        xorg.xkbcomp
        xorg.xmodmap
        xsel
        yoshimi
        zsh
      ];
    });
  };
}

# nixops bug
# system is on stable 16.09
# user's nix-channel is nixos-unstable
# nix-env -i nixos
# nix-env (whatever) fails
