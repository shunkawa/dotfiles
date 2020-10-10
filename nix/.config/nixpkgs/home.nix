{ lib, ... }:

# Required to get overlays, because home-manager clobbers pkgs
# https://github.com/nix-community/home-manager/issues/616
let pkgs = import <nixpkgs> {
  config = {
    allowUnfree = true;
  };
  overlays = [
    (import ./packages/overlay.nix)
  ];
}; in lib.mkMerge [
  ({
    programs.home-manager.enable = true;
    programs.home-manager.path = "<home-manager>";

    xdg.enable = true;

    manual.manpages.enable = false;

    home.packages = [
      (lib.lowPrio pkgs.inetutils) # prefer pkgs.whois over whois from pkgs.inetutils
      (pkgs.pass.overrideAttrs (attrs: { doInstallCheck = false; }))
      (pkgs.youtube-dl.override ({ phantomjsSupport = false; }))
      pkgs.aspell
      pkgs.aspellDicts.en
      pkgs.aspellDicts.en-computers
      pkgs.aspellDicts.en-science
      pkgs.bat
      pkgs.bind  # provides dig
      pkgs.bundler
      pkgs.coreutils
      pkgs.curl
      pkgs.direnv
      pkgs.entr
      pkgs.exa
      pkgs.fasd
      pkgs.fd
      pkgs.ffmpeg
      pkgs.file
      pkgs.findutils
      pkgs.fortune
      pkgs.fpp
      pkgs.fzf
      pkgs.git-lfs
      pkgs.gitAndTools.git-crypt
      pkgs.gitAndTools.gitFull
      pkgs.gitAndTools.hub
      pkgs.gitAndTools.pass-git-helper
      pkgs.gitAndTools.transcrypt
      pkgs.gnumake
      pkgs.gnupg
      pkgs.gnused
      pkgs.gnutar
      pkgs.go
      pkgs.grpcurl
      pkgs.htop
      pkgs.imagemagick
      pkgs.inkscape
      pkgs.isync
      pkgs.jhead
      pkgs.jq
      pkgs.kubernetes-helm
      pkgs.local-packages.comma
      pkgs.local-packages.curl-verbose
      pkgs.local-packages.docker-convenience-scripts
      pkgs.local-packages.emacs-with-packages
      pkgs.local-packages.git-archive-all
      pkgs.local-packages.goose
      pkgs.local-packages.hiptext
      pkgs.local-packages.mu
      pkgs.local-packages.node-build
      pkgs.local-packages.nodePackages."@jasondibenedetto/plop"
      pkgs.local-packages.nodenv
      pkgs.local-packages.open
      pkgs.local-packages.pass-show-first-line
      pkgs.local-packages.pinentry-wrapper
      pkgs.local-packages.remark-lint-wrapper
      pkgs.local-packages.tmux-packages.fzf-tmux-session
      pkgs.local-packages.tmux-packages.fzf-tmux-url
      pkgs.local-packages.tmux-packages.powerline
      pkgs.local-packages.tmux-packages.powerline-fonts
      pkgs.local-packages.tmux-packages.tmux-colors-solarized
      pkgs.local-packages.tmux-packages.tmux-copycat
      pkgs.local-packages.tmux-packages.tmux-fpp
      pkgs.local-packages.tmux-packages.tmux-open
      pkgs.local-packages.tmux-packages.tmux-pain-control
      pkgs.local-packages.tmux-packages.tmux-sensible
      pkgs.local-packages.tmux-packages.tmux-wrapper
      pkgs.local-packages.tmux-packages.tmux-yank
      pkgs.local-packages.zsh-packages.grml-zsh-config
      pkgs.local-packages.zsh-packages.nix-zsh-completions
      pkgs.local-packages.zsh-packages.oh-my-zsh
      pkgs.local-packages.zsh-packages.pure
      pkgs.local-packages.zsh-packages.zsh-autosuggestions
      pkgs.local-packages.zsh-packages.zsh-completions
      pkgs.local-packages.zsh-packages.zsh-syntax-highlighting
      pkgs.mitmproxy
      pkgs.mpv
      pkgs.msmtp
      pkgs.ncdu
      pkgs.ncmpcpp
      pkgs.nix-prefetch-scripts
      pkgs.nixpkgs-fmt
      pkgs.nmap
      pkgs.openssh
      pkgs.openssl
      pkgs.p7zip
      pkgs.pandoc
      pkgs.procmail # formail used for some mu hacks
      pkgs.procs
      pkgs.protobuf
      pkgs.pwgen
      pkgs.python3
      pkgs.qrencode
      pkgs.ripgrep
      pkgs.rsync
      pkgs.sd
      pkgs.shellcheck
      pkgs.socat
      pkgs.speedtest-cli
      pkgs.sqlite-interactive
      pkgs.stow
      pkgs.terraform
      pkgs.texlive.combined.scheme-full
      pkgs.toilet
      pkgs.tree
      pkgs.unrar
      pkgs.unzip
      pkgs.wget
      pkgs.which
      pkgs.whois # better than the one from inetutils
      pkgs.xclip
      pkgs.xsv
      pkgs.yq
      pkgs.yubikey-manager
      pkgs.zip
      pkgs.zsh
    ];
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
