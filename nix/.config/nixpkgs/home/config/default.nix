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
        ansible
        aspell
        aspellDicts.en
        bat
        bind
        bundler
        coreutils
        curl
        direnv
        docker_compose
        entr
        exa
        fasd
        fd
        feh
        file
        findutils
        fortune
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
        kubectl
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
        sift
        silver-searcher
        socat
        speedtest-cli
        sqlite-interactive
        stow
        toilet
        tree
        unrar
        unzip
        wget
        which
      ] ++ (with local-packages; [
        docker-convenience-scripts
        emacs-with-packages
        goose
        hiptext
        mu
        node-build
        nodenv
        pass-show-first-line
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
  (import ./syncthing {
    inherit lib pkgs;
    actualHostname = state.host;
  })
  (import ./tmux { inherit lib pkgs; })
  (import ./zsh { inherit lib pkgs; })
  (import ./xkb { inherit lib pkgs; })
  (import ./spectacle { inherit lib pkgs; })
  (import ./mbsync { inherit lib pkgs; })
])
