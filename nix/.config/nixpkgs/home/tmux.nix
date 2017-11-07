{ pkgs, lib, ... }:
let
  # tmuxCopycat = pkgs.fetchFromGitHub {
  # "url": "git@github.com:tmux-plugins/tmux-yank.git",
  # "rev": "feb9611b7d1c323ca54cd8a5111a53e3e8265b59",
  # "date": "2017-06-07T00:48:32-04:00",
  # "sha256": "1ywbm09jfh6cm2m6gracmdc3pp5p2dwraalbhfaafqaydjr22qc3",
  # "fetchSubmodules": true
  # }

  plugins = builtins.fromJSON (builtins.readFile ./tmux-plugins.json);

  tmuxWrapper = pkgs.runCommand pkgs.tmux.name {
    buildInputs = [ pkgs.makeWrapper ];
  } ''
    source $stdenv/setup

    mkdir -p $out/bin
    makeWrapper ${pkgs.tmux}/bin/tmux $out/bin/tmux \
    --set __ETC_BASHRC_SOURCED "" \
    --set __ETC_ZPROFILE_SOURCED  "" \
    --set __ETC_ZSHENV_SOURCED "" \
    --set __ETC_ZSHRC_SOURCED "" \
    --add-flags -f --add-flags /etc/tmux.conf
  '';
in {
  home.packages = [
    tmuxWrapper
  ];

  home.file.".tmux.conf".source = pkgs.writeText "tmux.conf" ''
    set -g default-terminal "screen-256color"
    set-option -g status-keys emacs
    set-option -gw mode-keys emacs

    # send the prefix to client inside window (nested sessions)
    bind-key a send-prefix
    # toggle last window
    bind-key C-\ last-window
    # confirm before killing a window or the server
    bind-key k confirm kill-window
    bind-key K confirm kill-server
    # toggle statusbar
    bind-key b set-option status
    # ctrl+left/right cycles thru windows
    bind-key -n C-right next
    bind-key -n C-left prev
    bind-key -n M-right next-window
    bind-key -n M-left previous-window

    # open a man page in new window
    # bind / command-prompt "split-window 'exec man %%'"
    # quick view of processes
    # bind '~' split-window "exec htop"
    # bind '"' split-window -c "#{pane_current_path}"
    # bind % split-window -h -c "#{pane_current_path}"
    bind c new-window -c "#{pane_current_path}"

    # listen for activity on all windows
    set -g bell-action any
    set -g visual-bell on
    # on-screen time for display-panes in ms
    set -g display-panes-time 2000
    # start window indexing at one instead of zero
    set -g base-index 1
    # enable wm window titles
    set -g set-titles on
    # window title string
    # set -g set-titles-string "tmux.#I.#W"

    # set -g message-bg colour0
    # set -g message-fg colour2
    set -g status-attr default
    set -g status-bg colour0
    set -g status-fg colour2
    set-option -g escape-time 0
    set-option -g mouse on
    set-option -g status on
    set-option -g status-interval 2
    # set-window-option -g window-status-activity-bg colour15
    # set-window-option -g window-status-activity-fg colour1
    # set-window-option -g window-status-current-bg colour2
    # set-window-option -g window-status-current-fg colour0
    setw -g aggressive-resize on
    setw -g monitor-activity on

    set -g message-bg colour0
    set -g message-fg colour2
    set-window-option -g window-status-activity-bg colour15
    set-window-option -g window-status-activity-fg colour1
    set-window-option -g window-status-current-bg colour2
    set-window-option -g window-status-current-fg colour0

    unbind C-b
    set -g prefix 'C-\'

    bind-key -n M-p run "tmux split-window -p 40 -c '#{pane_current_path}' 'tmux send-keys -t #{pane_id} \"$(fzf -m | paste -sd\\  -)\"'"

    run-shell "${pkgs.pythonPackages.powerline}/bin/powerline-daemon -q"
    source "${pkgs.pythonPackages.powerline}/share/tmux/powerline.conf"

    run-shell ~/.local/share/tmux/tmux-yank/yank.tmux
    # run-shell ~/.local/share/tmux/tmux-copycat/copycat.tmux # doesn't work at all right now
    run-shell ~/.local/share/tmux/tmux-pain-control/pain_control.tmux
    run-shell ~/.local/share/tmux/tmux-sensible/sensible.tmux
  '';
}
