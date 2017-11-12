{ pkgs, lib, ... }:
let
  bleedingEdgePackages = (builtins.fromJSON (builtins.readFile ./tmux-packages.json));

  tmux-sensible = pkgs.fetchgit {
    inherit (bleedingEdgePackages.tmux-sensible) url rev sha256;
  };

  tmux-pain-control = pkgs.fetchgit {
    inherit (bleedingEdgePackages.tmux-pain-control) url rev sha256;
  };

  tmux-fpp = pkgs.fetchgit {
    inherit (bleedingEdgePackages.tmux-fpp) url rev sha256;
  };

  tmux-yank = pkgs.fetchgit {
    inherit (bleedingEdgePackages.tmux-yank) url rev sha256;
  };

  tmux-copycat = pkgs.fetchgit {
    inherit (bleedingEdgePackages.tmux-copycat) url rev sha256;
  };

  tmux-open = pkgs.fetchgit {
    inherit (bleedingEdgePackages.tmux-open) url rev sha256;
  };

  tmux-colors-solarized = pkgs.fetchgit {
    inherit (bleedingEdgePackages.tmux-colors-solarized) url rev sha256;
  };

  tmuxWrapper = pkgs.runCommand pkgs.tmux.name {
    buildInputs = [ pkgs.makeWrapper ];
  } ''
    source $stdenv/setup

    mkdir -p $out/bin

    makeWrapper ${pkgs.tmux}/bin/tmux $out/bin/tmux \
      --add-flags -2
  '';
in {
  home.packages = [
    tmuxWrapper
    pkgs.fpp
    pkgs.fzf
    pkgs.pythonPackages.powerline
    pkgs.powerline-fonts
  ];

  home.file.".tmux.conf".source = pkgs.writeText "tmux.conf" ''
    bind / command-prompt "split-window 'exec man %%'"
    bind '~' split-window "exec ${pkgs.htop}"

    bind-key -n M-p run "${pkgs.tmux} split-window -p 40 -c '#{pane_current_path}' '${pkgs.tmux} send-keys -t #{pane_id} \"$(${pkgs.fzf} -m | paste -sd\\  -)\"'"

    unbind C-b
    set -g prefix 'C-\'

    # tmux-sensible tries to set make the prefix key without control act as
    # last-window, but it doesn't work for this prefix
    bind-key \ last-window
    bind-key C-\ last-window

    bind-key -n M-right next-window
    bind-key -n M-left previous-window

    set-option -g status-keys emacs
    set-option -gw mode-keys emacs

    set-option -g mouse on

    run-shell "${pkgs.pythonPackages.powerline}/bin/powerline-daemon -q"
    run-shell "${pkgs.pythonPackages.powerline}/bin/powerline-config tmux setup"
    run-shell "${tmux-sensible}/sensible.tmux"
    run-shell "${tmux-pain-control}/pain_control.tmux"
    run-shell "${tmux-yank}/yank.tmux"
    run-shell "${tmux-copycat}/copycat.tmux"
    run-shell "${tmux-fpp}/fpp.tmux"
    run-shell "${tmux-open}/open.tmux"
    run-shell "${tmux-colors-solarized}/tmuxcolors.tmux"
  '';
}
