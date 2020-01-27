{ pkgs, lib, ... }:
let
  bleedingEdgePackages = (builtins.fromJSON (builtins.readFile ./zsh-packages.json));

  dircolors-solarized = pkgs.fetchgit {
    inherit (bleedingEdgePackages.dircolors-solarized) url rev sha256;
  };

  grml-etc-core = pkgs.fetchgit {
    inherit (bleedingEdgePackages.grml-etc-core) url rev sha256;
  };

  oh-my-zsh = pkgs.fetchgit {
    inherit (bleedingEdgePackages.oh-my-zsh) url rev sha256;
  };

  nix-zsh-completions = let
    src = pkgs.fetchgit {
      inherit (bleedingEdgePackages.nix-zsh-completions) url rev sha256;
    };
  in (pkgs.runCommand "nix-zsh-completions" {} ''
    mkdir -p $out/completions
    cp ${src}/* $out/completions
  '');

  plop = pkgs.local-packages.nodePackages."@jasondibenedetto/plop";

  pure = pkgs.fetchgit {
    inherit (bleedingEdgePackages.pure) url rev sha256;
  };

  write-out = pkgs.writeText "write-out" ''
    \n*** cURL says:\n
    content_type       = %{content_type}\n
    filename_effective = %{filename_effective}\n
    ftp_entry_path     = %{ftp_entry_path}\n
    http_code     n     = %{http_code}\n
    http_connect       = %{http_connect}\n
    local_ip           = %{local_ip}\n
    local_port         = %{local_port}\n
    num_connects       = %{num_connects}\n
    num_redirects      = %{num_redirects}\n
    redirect_url       = %{redirect_url}\n
    remote_ip          = %{remote_ip}\n
    remote_port        = %{remote_port}\n
    size_download      = %{size_download} bytes\n
    size_header        = %{size_header} bytes\n
    size_request       = %{size_request} bytes\n
    size_upload        = %{size_upload} bytes\n
    speed_download     = %{speed_download} bytes per second\n
    speed_upload       = %{speed_upload} bytes per second\n
    ssl_verify_result  = %{ssl_verify_result}\n
    time_appconnect    = %{time_appconnect} seconds\n
    time_connect       = %{time_connect} seconds\n
    time_namelookup    = %{time_namelookup} seconds\n
    time_pretransfer   = %{time_pretransfer} seconds\n
    time_redirect      = %{time_redirect} seconds\n
    time_starttransfer = %{time_starttransfer} seconds\n
    time_total         = %{time_total} seconds\n
    url_effective      = %{url_effective}\n
  '';

  zsh-autosuggestions = pkgs.fetchgit {
    inherit (bleedingEdgePackages.zsh-autosuggestions) url rev sha256;
  };

  zsh-completions = pkgs.fetchgit {
   inherit (bleedingEdgePackages.zsh-completions) url rev sha256;
  };

  zsh-syntax-highlighting = pkgs.fetchgit {
    inherit (bleedingEdgePackages.zsh-syntax-highlighting) url rev sha256;
  };

in (lib.recursiveUpdate ({
  home.packages = with pkgs; [
    coreutils
    direnv
    fzf
    gitAndTools.gitFull
    zsh
  ];

  home.file.".config/zsh/functions/prompt_pure_setup".source = (pkgs.runCommand "prompt_pure_setup" {} ''
    cp "${pure}/pure.zsh" $out
  '');

  home.file.".config/zsh/functions/async".source = (pkgs.runCommand "async" {} ''
    cp "${pure}/async.zsh" $out
  '');

  # TODO: this should use WARC format
  home.file.".config/zsh/functions/mirror".source = pkgs.writeText "mirror" ''
    #!/usr/bin/env zsh

    # Mirror a website or some subdirectory
    function mirror() {
      ${pkgs.wget}/bin/wget \
        --mirror \
        --page-requisites \
        --adjust-extension \
        --no-parent \
        --convert-links \
        --execute robots=off \
        "''${1}"
    }

    mirror "''${@}"
  '';

  # TODO: figure out how to get the output path and create a symlink to it, for
  # example so that a command like this:
  # $ get-page http://chriswarbo.net/projects/nixos/useful_hacks.html
  # produces a symlink like this:
  # $ ls -lha useful-nix-hacks.html
  # useful-nix-hacks.html-> ./.wget/chriswarbo.net/projects/nixos/useful_hacks.html
  home.file.".config/zsh/functions/get-page".source = pkgs.writeText "get-page" ''
    #!/usr/bin/env zsh

    function get-page () {
      ${pkgs.wget}/bin/wget \
        --adjust-extension \
        --span-hosts \
        --convert-links \
        --page-requisites \
        --no-clobber \
        --execute robots=off \
        "''${1}"
    }

    get-page "''${@}"
  '';

  home.file.".config/zsh/functions/fplop".source = pkgs.writeText "fplop" ''
    #!/usr/bin/env zsh

    function fplop() {
      echo "\$$(${plop}/bin/plop -k $1): #$1;" | tr "[:upper:]" "[:lower:]"
    }

    fplop "''${@}"
  '';

  home.file.".config/zsh/functions/get-images-from-pdf".source = pkgs.writeText "get-images-from-pdf" ''
    #!/usr/bin/env zsh

    function get-images-from-pdf() {
      ${pkgs.ghostscript}/bin/gs \
        -dBATCH \
        -dNOPAUSE \
        -sDEVICE=png16m \
        -dGraphicsAlphaBits=4 \
        -dTextAlphaBits=4 \
        -r150 \
        -sOutputFile=./output%d.png \
        ''${1};
    }

    get-images-from-pdf "''${@}"
  '';

  home.file.".config/zsh/functions/install-package-and-peerdependencies".source = pkgs.writeText "install-package-and-peerdependencies" ''
    #!/usr/bin/env zsh

    function install-package-and-peerdependencies () {
      if $(command -v npm >/dev/null 2>&1 && command -v yarn >/dev/null 2>&1); then
        npm info "$1@latest" peerDependencies --json \
          | command ${pkgs.gnused}/bin/sed 's/[\{\},]//g ; s/: /@/g' \
          | ${pkgs.findutils}/bin/xargs yarn add --dev "$1@latest"
      else
        echo '** ERROR:' "npm or yarn not found in \$PATH" >&2
        exit 1
      fi
    }

    install-package-and-peerdependencies "''${@}"
  '';

  home.file.".config/zsh/functions/get-ssl-certificate-expiry-date".source = pkgs.writeText "get-ssl-certificate-expiry-date" ''
    #!/usr/bin/env zsh

    function get-ssl-certificate-expiry-date() {
      ${pkgs.openssl}/bin/openssl s_client -showcerts -connect "$(echo ''${1} \
        | ${pkgs.gnused}/bin/sed 's,http\(s\|\)://,,'):443" </dev/null \
        | ${pkgs.openssl}/bin/openssl x509 -enddate -noout \
        | ${pkgs.gnugrep}/bin/grep notAfter
    }

    get-ssl-certificate-expiry-date "''${@}"
  '';

  home.file.".config/zsh/functions/emacs".source = pkgs.writeText "emacs" ''
    #!/usr/bin/env zsh

    function emacs() {
      if isdarwin; then
        ${pkgs.local-packages.emacs-with-packages}/Applications/Emacs.app/Contents/MacOS/Emacs "''${@}";
      else
        ${pkgs.local-packages.emacs-with-packages}/bin/emacs "''${@}"
      fi;
    }

    emacs "''${@}"
  '';

  home.file.".config/zsh/functions/rkm-history".source = pkgs.writeText "rkm-history" ''
    #!/usr/bin/env zsh

    function rkm-history () {
      LC_ALL=C; cat "''${RKM_HISTORY_HIST_DIR}/"** |
        ${pkgs.gnused}/bin/sed "s/^[^;]*;//" | # assuming EXTENDED_HISTORY is set (":start:elapsed;command" format)
        sort |
        uniq -c |
        sort |
        ${pkgs.gnused}/bin/sed "s/^[[:space:]]*[0-9]*[[:space:]]*//"
    }

    rkm-history "''${@}"
  '';

  home.file.".zshenv".source = pkgs.writeText "zshenv" ''
    export LC_ALL=en_US.UTF-8
    export LANG=en_US.UTF-8
    export LANGUAGE=en_US.UTF-8

    fpath=(
      ''${HOME}/.config/zsh/functions
      ${zsh-completions}/src
      ${nix-zsh-completions}/completions
      ${oh-my-zsh}/plugins/docker
      ${oh-my-zsh}/plugins/docker-compose
      ${oh-my-zsh}/plugins/docker-machine
      ''${fpath[@]}
    )

    # Don't use x11-ssh-askpass
    unset SSH_ASKPASS

    export MSMTP_QUEUE="''${HOME}/.cache/msmtp/queue"
    test -d "$MSMTP_QUEUE" || mkdir -p "$MSMTP_QUEUE"
    export MSMTP_LOG="''${MSMTP_QUEUE}/log"
    test -f "$MSMTP_LOG" || touch "$MSMTP_LOG"
    # Use faster ping test when msmtpq tests for a connection
    export EMAIL_CONN_TEST="P"
    # Gnus pipes the output of `sendmail-program' to a buffer and expects it to be
    # empty if there was no error.  Suppress the chattiness of msmtpq to avoid errors
    # from this
    export EMAIL_QUEUE_QUIET="t"

    export WINEARCH=win32
    export WINEPREFIX="''${HOME}/.wine32"

    export LESSHISTFILE="/dev/null"
    export LC_COLLATE="C"
    export PAGER="less -R"
    export EDITOR="emacsclient -c -a vi"
    export VISUAL="emacsclient -c -a vi"

    export FZF_TMUX="1"
    export FZF_ALT_C_COMMAND="fd --type d --hidden --follow"
    export FZF_CTRL_T_COMMAND="fd --type f --hidden --follow"

    export LESS="$LESS -FRXK"
  '';

  home.file.".zshrc".source = pkgs.writeText "zshrc" ''
    source "${grml-etc-core}/etc/zsh/zshrc"

    for i in ''${HOME}/.config/zsh/functions/*; do autoload -Uz "$(basename $i)"; done

    if [[ -z "$(pgrep gpg-agent)" ]]; then
      eval "$(gpg-agent --daemon --enable-ssh-support --sh)"
    fi

    # Don't let gnome's ssh agent clobber this variable
    if isdarwin; then
      export SSH_AUTH_SOCK="$HOME/.gnupg/S.gpg-agent.ssh"
    else
      export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/gnupg/S.gpg-agent.ssh"
    fi

    # clear out residual grml prompt stuff
    zstyle ':prompt:grml:left:setup' items
    zstyle ':prompt:grml:right:setup' items
    RPS1="" #

    autoload -U promptinit; promptinit
    prompt pure

    stty -ixon # disable stop
    # Get rid of pause on control-S
    # stty stop '^[[5~' # Pause key

    autoload -U select-word-style
    select-word-style bash

    # Tramp doesn't work if the prompt doesn't match its regexp
    if [[ "$TERM" == "dumb" ]]
    then
      unsetopt zle
      unsetopt prompt_cr
      unsetopt prompt_subst
      unfunction precmd # may not exist on Debian Jessie
      unfunction preexec # may not exist on Debian Jessie
      PS1='$ '
    fi

    # Prevent accidentally clobbering files
    alias rm="rm -iv"
    alias cp="cp -ivr"
    alias mv="mv -iv"
    set -o noclobber

    alias l='exa -la'
    alias ll='l'

    alias e='emacs-client'
    alias e.='e'

    source "${oh-my-zsh}/plugins/colored-man-pages/colored-man-pages.plugin.zsh"

    source "${zsh-autosuggestions}/zsh-autosuggestions.zsh"

    bindkey '^ ' autosuggest-accept # C-SPACE

    source "${nix-zsh-completions}/completions/nix.plugin.zsh"
    prompt_nix_shell_setup

    source "${pkgs.fzf}/share/fzf/completion.zsh"
    source "${pkgs.fzf}/share/fzf/key-bindings.zsh"

    source "${zsh-syntax-highlighting}/zsh-syntax-highlighting.zsh"

    # See "4.5.3: Function keys and so on" for help figuring out how to type a
    # particular key binding
    # http://zsh.sourceforge.net/Guide/zshguide04.html#l96

    # Remove fzf's suggested bindings that conflict with emacs keys
    bindkey -r '^T'  # fzf-file-widget
    bindkey '\e[17~' fzf-file-widget # F6
    bindkey '^T' transpose-chars # restore original binding

    bindkey -r '\ec' # fzf-cd-widget
    bindkey '\e[15~' fzf-cd-widget # F5
    bindkey '\ec' capitalize-word # restore original binding

    # History stuff inspired by a comment by howeyc on Hacker News:
    #
    # "I do something very similar, but without the prompt settings. I have settings
    # in .bashrc[0] to have the history file based on date. I then use fzf[1]
    # (fzf-tmux is great) and a grep-like tool(sift[2]) to use for ctrl-r that
    # fuzzy-searches history and orders by usage frequency[3]. This way I can easily
    # search for the command I'm thinking of fairly quickly. Particularly useful for
    # those times I want to run a command again that was quite long or had more than
    # a couple options/flags."
    #
    # See the thread at https://news.ycombinator.com/item?id=11806748
    #
    # Resources:
    # http://sgeb.io/posts/2014/04/zsh-zle-custom-widgets/
    # https://github.com/junegunn/fzf/blob/master/shell/key-bindings.zsh

    # This shadows the fzf-history-widget from share/fzf/key-bindings.zsh
    fzf-history-widget() {
      local selected num
      setopt localoptions noglobsubst pipefail 2> /dev/null
      selected=(
        $(rkm-history |
            FZF_DEFAULT_OPTS="--height ''${FZF_TMUX_HEIGHT:-40%} --reverse $FZF_DEFAULT_OPTS +s --tac -n2..,.. --tiebreak=index --bind=ctrl-r:toggle-sort $FZF_CTRL_R_OPTS --query=''${(q)LBUFFER} +m" $(__fzfcmd) -q '^'
        )
      )
      local ret=$?
      if [ -n "''${selected}" ]; then
        zle kill-whole-line # in case something was already there
      fi
      LBUFFER="''${selected}"
      zle redisplay
      return $ret
    }

    zle     -N   fzf-history-widget
    bindkey '^S' fzf-history-widget
    bindkey '^R' fzf-history-widget

    # Use fd (https://github.com/sharkdp/fd) instead of the default find
    # command for listing path candidates.
    # - The first argument to the function ($1) is the base path to start traversal
    # - See the source code (completion.{bash,zsh}) for the details.
    _fzf_compgen_path() {
      fd --hidden --follow --exclude ".git" . "''${1}"
    }

    # Use fd to generate the list for directory completion
    _fzf_compgen_dir() {
      fd --type d --hidden --follow --exclude ".git" . "''${1}"
    }

    export RKM_HISTORY_HIST_DIR="''${HOME}/sync/history/zsh"
    test -d "$RKM_HISTORY_HIST_DIR" || mkdir -p "$RKM_HISTORY_HIST_DIR"
    export HISTFILE="$(rkm-history-create-histfile-name)"
    HISTSIZE=1000000
    SAVEHIST=$HISTSIZE

    setopt BANG_HIST                 # Treat the '!' character specially during expansion.
    setopt EXTENDED_HISTORY          # Write the history file in the ":start:elapsed;command" format.
    setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits.
    setopt SHARE_HISTORY             # Share history between all sessions.
    setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first when trimming history.
    setopt HIST_IGNORE_DUPS          # Don't record an entry that was just recorded again.
    setopt HIST_IGNORE_ALL_DUPS      # Delete old recorded entry if new entry is a duplicate.
    setopt HIST_FIND_NO_DUPS         # Do not display a line previously found.
    setopt HIST_IGNORE_SPACE         # Don't record an entry starting with a space.
    setopt HIST_SAVE_NO_DUPS         # Don't write duplicate entries in the history file.
    setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks before recording entry.
    setopt HIST_VERIFY               # Don't execute immediately upon history expansion.
    setopt HIST_BEEP                 # Beep when accessing nonexistent history.

    if $(command -v kubectl >/dev/null 2>&1); then
      source <(kubectl completion zsh)
    fi

    if $(command -v aws_bash_completer >/dev/null 2>&1); then
      source $(command -v aws_bash_completer)
    fi

    if $(command -v nodenv >/dev/null 2>&1); then
      export PATH="''${HOME}/.nodenv/shims:''${PATH}"
      eval "$(nodenv init - zsh)"
    fi

    export PATH="''${HOME}/.local/bin:''${PATH}"

    if $(command -v direnv >/dev/null 2>&1); then
      eval "$(direnv hook zsh)"
    fi

    if $(command -v direnv >/dev/null 2>&1); then
      eval "$(fasd --init auto)"
    fi

    export NPM_CONFIG_INIT_AUTHOR_EMAIL="ruben@maher.fyi"
    export NPM_CONFIG_INIT_AUTHOR_NAME="Ruben Maher"
    export NPM_CONFIG_GIT_TAG_VERSION="false"
    export NPM_CONFIG_CACHE="$HOME/.cache/npm"
    # For per-directory or project configuration (private registries, etc), do
    # something like this in .envrc:
    # export NPM_CONFIG_USERCONFIG="$(pwd)/npmrc"

    join-lines() {
      local item
      while read item; do
        echo -n "''${(q)item} "
      done
    }

    bind-git-helper() {
      local c
      for c in $@; do
        eval "fzf-g$c-widget() { local result=\$(g$c | join-lines); zle reset-prompt; LBUFFER+=\$result }"
        eval "zle -N fzf-g$c-widget"
        eval "bindkey '^g^$c' fzf-g$c-widget"
      done
    }
    bind-git-helper f b t r h
    unset -f bind-git-helper
  '';

  home.file.".zlogout".source = pkgs.writeText "zlogout" ''
    clear
  '';
}) (lib.foldr (a: b: lib.recursiveUpdate a b) {}
  (lib.mapAttrsToList
    (name: value: {
      home.file.".config/zsh/functions/${name}".source =
        (./functions + "/${name}");
    }) (builtins.readDir ./functions))))
