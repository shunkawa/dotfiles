{ pkgs, lib, ... }:

let
  state = (builtins.fromJSON (builtins.readFile ./state.json));
in lib.mkMerge ([
  {
    programs.home-manager.enable = true;
    programs.home-manager.path = "<home-manager>";

    xdg.enable = true;

    manual.manpages.enable = false;

    home = {
      file.".psqlrc".source = pkgs.writeText "psqlrc" ''
        \x auto
      '';

      packages = with pkgs; [
        (pass.overrideAttrs (attrs: { doInstallCheck = false; }))
        aspell
        aspellDicts.en
        aspellDicts.en-computers
        aspellDicts.en-science
        bat
        bind
        bundler
        coreutils
        curl
        direnv
        entr
        exa
        fasd
        fd
        feh
        file
        findutils
        fortune
        fpp
        fzf
        ghq
        git-lfs
        gitAndTools.git-crypt
        gitAndTools.gitFull
        gitAndTools.hub
        gitAndTools.pass-git-helper
        gitAndTools.transcrypt
        gnumake
        gnupg
        gnused
        gnutar
        go
        htop
        imagemagick
        inkscape
        isync
        jhead
        jq
        kubernetes-helm
        mitmproxy
        msmtp
        ncmpcpp
        nix-prefetch-scripts
        nmap
        openssh
        openssl
        pandoc
        procmail # formail used for some mu hacks
        protobuf
        pwgen
        python3
        qrencode
        ripgrep
        rsync
        shellcheck
        socat
        speedtest-cli
        sqlite-interactive
        stow
        texlive.combined.scheme-full
        toilet
        tree
        unrar
        unzip
        wget
        xclip
        xe
        yq
        yubikey-manager
        zsh
      ] ++ (with local-packages; [
        comma
        curl-verbose
        docker-convenience-scripts
        emacs-with-packages
        git-archive-all
        goose
        grpcurl
        hiptext
        mu
        node-build
        nodePackages."@jasondibenedetto/plop"
        nodenv
        pass-show-first-line
        pinentry-wrapper
        tmux-packages.fzf-tmux-session
        tmux-packages.fzf-tmux-url
        tmux-packages.powerline
        tmux-packages.powerline-fonts
        tmux-packages.tmux-colors-solarized
        tmux-packages.tmux-copycat
        tmux-packages.tmux-fpp
        tmux-packages.tmux-open
        tmux-packages.tmux-pain-control
        tmux-packages.tmux-sensible
        tmux-packages.tmux-wrapper
        tmux-packages.tmux-yank
        zsh-packages.grml-zsh-config
        zsh-packages.nix-zsh-completions
        zsh-packages.oh-my-zsh
        zsh-packages.pure
        zsh-packages.zsh-autosuggestions
        zsh-packages.zsh-completions
        zsh-packages.zsh-syntax-highlighting
      ]) ++ lib.optionals stdenv.isLinux ([
          anki
          chromium
          desmume
          discord
          firefox
          gimp
          libreoffice
          mpv
          pinentry
          shellcheck # ghc isn't available from any cache on darwin
          vdirsyncer
          youtube-dl
        ]
        ++ (with pkgs.ibus-engines; [ local-packages.ibus-engines.mozc uniemoji ])
        ++ (with local-packages; [open]))
      ++ lib.optionals stdenv.isDarwin ([
        pinentry_mac
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
  # (import ./syncthing {
  #   inherit lib pkgs;
  #   actualHostname = state.host;
  # })
  (import ./xkb { inherit lib pkgs; })
  (import ./spectacle { inherit lib pkgs; })
  (import ./mbsync { inherit lib pkgs; })
])
