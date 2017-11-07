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

  tmuxWrapper = pkgs.runCommand pkgs.tmux.name {
    buildInputs = [ pkgs.makeWrapper ];
  } ''
    source $stdenv/setup

    mkdir -p $out/bin

    makeWrapper ${pkgs.tmux}/bin/tmux $out/bin/tmux
  '';
in {
  home.packages = [
    tmuxWrapper
    pkgs.fpp
  ];

  home.file.".tmux.conf".source = pkgs.writeText "tmux.conf" ''
    # set -g default-terminal "screen-256color"

    # send the prefix to client inside window (nested sessions)
    # bind-key a send-prefix
    # toggle last window
    # # confirm before killing a window or the server
    # bind-key k confirm kill-window
    # bind-key K confirm kill-server
    # # toggle statusbar
    # bind-key b set-option status
    # # ctrl+left/right cycles thru windows
    # bind-key -n C-right next
    # bind-key -n C-left prev

    # open a man page in new window
    # bind / command-prompt "split-window 'exec man %%'"
    # quick view of processes
    # bind '~' split-window "exec htop"
    # bind '"' split-window -c "#{pane_current_path}"
    # bind % split-window -h -c "#{pane_current_path}"
    # bind c new-window -c "#{pane_current_path}"

    # # listen for activity on all windows
    # set -g bell-action any
    # set -g visual-bell on
    # # on-screen time for display-panes in ms
    # set -g display-panes-time 2000
    # # start window indexing at one instead of zero
    # set -g base-index 1
    # # enable wm window titles
    # set -g set-titles on
    # # window title string
    # # set -g set-titles-string "tmux.#I.#W"

    # # set -g message-bg colour0
    # # set -g message-fg colour2
    # set -g status-attr default
    # set -g status-bg colour0
    # set -g status-fg colour2
    # set-option -g escape-time 0
    # set-option -g mouse on
    # set-option -g status on
    # set-option -g status-interval 2
    # # set-window-option -g window-status-activity-bg colour15
    # # set-window-option -g window-status-activity-fg colour1
    # # set-window-option -g window-status-current-bg colour2
    # # set-window-option -g window-status-current-fg colour0
    # setw -g aggressive-resize on
    # setw -g monitor-activity on

    # set -g message-bg colour0
    # set -g message-fg colour2
    # set-window-option -g window-status-activity-bg colour15
    # set-window-option -g window-status-activity-fg colour1
    # set-window-option -g window-status-current-bg colour2
    # set-window-option -g window-status-current-fg colour0

    # bind-key -n M-p run "tmux split-window -p 40 -c '#{pane_current_path}' 'tmux send-keys -t #{pane_id} \"$(fzf -m | paste -sd\\  -)\"'"

    unbind C-b
    set -g prefix 'C-\'

    bind-key C-\ last-window
    bind-key -n M-right next-window
    bind-key -n M-left previous-window

    set-option -g status-keys emacs
    set-option -gw mode-keys emacs

    run-shell "${pkgs.pythonPackages.powerline}/bin/powerline-daemon -q"
    run-shell "${pkgs.pythonPackages.powerline}/bin/powerline-config tmux setup"
    run-shell "${tmux-sensible}/sensible.tmux"
    run-shell "${tmux-pain-control}/pain_control.tmux"
    run-shell "${tmux-yank}/yank.tmux"
    run-shell "${tmux-copycat}/copycat.tmux"
    run-shell "${tmux-fpp}/fpp.tmux"
    run-shell "${tmux-open}/open.tmux"
  '';
}
