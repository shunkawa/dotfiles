{ pkgs, lib, ... }:

lib.mkMerge [
  ({
    programs.home-manager.enable = true;
    programs.home-manager.path = "<home-manager>";

    xdg.enable = true;

    manual.manpages.enable = false;

    home.packages = with pkgs; [
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
      du-dust
      entr
      exa
      fasd
      fd
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
      hyperfine
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
      nixpkgs-fmt
      nmap
      openssh
      openssl
      pandoc
      procmail # formail used for some mu hacks
      procs
      protobuf
      pwgen
      python3
      qrencode
      ripgrep
      rsync
      sd
      shellcheck
      socat
      speedtest-cli
      sqlite-interactive
      stow
      terraform
      texlive.combined.scheme-full
      toilet
      tree
      unrar
      unzip
      wget
      xclip
      xe
      xsv
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
      remark-lint-wrapper
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
      vdirsyncer
      youtube-dl
    ]
    ++ (with pkgs.ibus-engines; [ local-packages.ibus-engines.mozc uniemoji ])
    ++ (with local-packages; [ open ]))
    ++ lib.optionals stdenv.isDarwin ([
      (youtube-dl.override ({ phantomjsSupport = false; }))
      mpv
    ]);
  })

  (lib.mkIf
    pkgs.stdenv.isLinux
    {
      # I like to use the Hyper key in Emacs, but by default Gnome treats it the
      # same as Super so Hyper + L will lock the screen instead of navigating to the
      # pane to the right.
      #
      # This solution is from the answer here:
      #
      # https://askubuntu.com/questions/423627/how-to-make-hyper-and-super-keys-not-do-the-same-thing
      home.file.".config/xkb/symbols/local".source = pkgs.writeText "super-hyper" ''
        default  partial modifier_keys
        xkb_symbols "superhyper" {
          modifier_map Mod3 { Super_L, Super_R };

          key <SUPR> {    [ NoSymbol, Super_L ]   };
          modifier_map Mod3   { <SUPR> };

          key <HYPR> {    [ NoSymbol, Hyper_L ]   };
          modifier_map Mod4   { <HYPR> };
        };
      '';

      systemd.user.services.xkb-separate-super-and-hyper = {
        Unit = {
          Description = "Put super and hyper on different modifiers";
          After = [ "graphical-session-pre.target" ];
          PartOf = [ "graphical-session.target" ];
        };

        Service = {
          ExecStart = builtins.toString (pkgs.writeScript "xkb-separate-super-and-hyper" ''
            #!${pkgs.stdenv.shell}
            ${pkgs.xorg.setxkbmap}/bin/setxkbmap -print \
              | ${pkgs.gnused}/bin/sed -e '/xkb_symbols/s/"[[:space:]]/+local&/' \
              | ${pkgs.xorg.xkbcomp}/bin/xkbcomp -I''${HOME}/.config/xkb - ''${DISPLAY}
          '');
          Type = "oneshot";
        };

        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };

      systemd.user.timers.xkb-separate-super-and-hyper = {
        Unit = {
          Description = "Put super and hyper on different modifiers";
        };

        Timer = {
          OnUnitActiveSec = "5min";
        };

        Install = {
          WantedBy = [ "timers.target" ];
        };
      };
    })
]
