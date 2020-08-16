{ callPackage
, tmuxPlugins
, powerline-fonts
, python3Packages
}: {
  fzf-tmux-url = tmuxPlugins.fzf-tmux-url;

  fzf-tmux-session = callPackage
    ({ stdenv, writeScriptBin }: writeScriptBin "fzf-tmux-session" ''
      #!${stdenv.shell}
      set -e
      session=$(tmux list-sessions -F '#{session_name}' | fzf --query="''${1}" --exit-0)
      tmux switch-client -t "$session"
    '') { };

  powerline = python3Packages.powerline.override ({ i3ipc = null; });

  inherit powerline-fonts;

  tmux-colors-solarized = tmuxPlugins.tmux-colors-solarized;

  tmux-copycat = tmuxPlugins.copycat;

  tmux-fpp = tmuxPlugins.fpp;

  tmux-open = tmuxPlugins.open;

  tmux-pain-control = tmuxPlugins.pain-control;

  tmux-sensible = tmuxPlugins.sensible;

  tmux-wrapper = callPackage
    ({ runCommand, tmux, makeWrapper }:
      runCommand
        tmux.name
        {
          buildInputs = [ makeWrapper ];
        } ''
        source $stdenv/setup

        mkdir -p $out/bin

        # Force tmux to start in 256 colors mode, whether or not $TERM says it is
        # supported
        # https://github.com/tmux/tmux/wiki/FAQ#how-do-i-use-a-256-colour-terminal
        makeWrapper ${tmux}/bin/tmux $out/bin/tmux \
          --set __NIX_DARWIN_SET_ENVIRONMENT_DONE 1 \
          --set __ETC_ZSHENV_SOURCED 1 \
          --add-flags -2
      ''
    ) { };

  tmux-yank = tmuxPlugins.yank;
}
