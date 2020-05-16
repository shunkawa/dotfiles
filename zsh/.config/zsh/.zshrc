if test -f "${NIX_PROFILE}/etc/zsh/zshrc"; then
  source "${NIX_PROFILE}/etc/zsh/zshrc"
else
  echo "Not found: ${NIX_PROFILE}/etc/zsh/zshrc"
fi

for i in ${HOME}/.config/zsh/functions/*; do autoload -Uz "$(basename $i)"; done

autoload -Uz compinit
for dump in "${COMPDUMPFILE}"(N.mh+24); do
  compinit
done
compinit -C

if (command -v pgrep gpg-agent >/dev/null 2>&1); then
  if test -z "$(pgrep gpg-agent)"; then
    eval "$(gpg-agent --daemon --enable-ssh-support --sh)"
  fi
fi

# Don't let gnome's ssh agent clobber this variable
if isdarwin; then
  export SSH_AUTH_SOCK="$HOME/.gnupg/S.gpg-agent.ssh"
else
  export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/gnupg/S.gpg-agent.ssh"
fi

if test -f "${NIX_PROFILE}/share/zsh/site-functions/prompt_pure_setup"; then
  # clear out residual grml prompt stuff
  zstyle ':prompt:grml:left:setup' items
  zstyle ':prompt:grml:right:setup' items
  RPS1=""
  # Prevents Pure from checking whether the current Git remote has been updated.
  export PURE_GIT_PULL=0
  prompt pure
else
  echo "Not found: ${NIX_PROFILE}/share/zsh/site-functions/prompt_pure_setup"
fi

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

if test -f "${NIX_PROFILE}/share/oh-my-zsh/plugins/colored-man-pages/colored-man-pages.plugin.zsh"; then
  source "${NIX_PROFILE}/share/oh-my-zsh/plugins/colored-man-pages/colored-man-pages.plugin.zsh"
else
  echo "Not found: ${NIX_PROFILE}/share/oh-my-zsh/plugins/colored-man-pages/colored-man-pages.plugin.zsh"
fi

if test -f "${NIX_PROFILE}/share/zsh/plugins/autosuggestions/zsh-autosuggestions.plugin.zsh"; then
  source "${NIX_PROFILE}/share/zsh/plugins/autosuggestions/zsh-autosuggestions.plugin.zsh"
  bindkey '^ ' autosuggest-accept # C-SPACE
else
  echo "Not found: ${NIX_PROFILE}/share/zsh/plugins/autosuggestions/zsh-autosuggestions.plugin.zsh"
fi

if test -f "${NIX_PROFILE}/share/zsh/plugins/nix/nix.plugin.zsh"; then
  source "${NIX_PROFILE}/share/zsh/plugins/nix/nix.plugin.zsh"
else
  echo "Not found: ${NIX_PROFILE}/share/zsh/plugins/nix/nix.plugin.zsh"
fi

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

function fzf-history-widget-rkm () {
  local selected num
  setopt localoptions noglobsubst pipefail 2> /dev/null
  selected=(
    $(rkm-history |
        FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse $FZF_DEFAULT_OPTS +s --tac -n2..,.. --tiebreak=index --bind=ctrl-r:toggle-sort $FZF_CTRL_R_OPTS --query=${(q)LBUFFER} +m" $(__fzfcmd) -q '^'
    )
  )
  local ret=$?
  if [ -n "${selected}" ]; then
    zle kill-whole-line # in case something was already there
  fi
  LBUFFER="${selected}"
  zle redisplay
  return $ret
}

function join-lines () {
  local item
  while read item; do
    echo -n "${(q)item} "
  done
}

function bind-fzf-git-helper () {
  local key="${1}"
  local cmd="${2}"

  eval "fzf-git-${key}-widget() { local result=\$(${cmd} | join-lines); zle reset-prompt; LBUFFER+=\$result }"
  eval "zle -N fzf-git-${key}-widget"
  eval "bindkey '^g^$c' fzf-git-${key}-widget"
}

if (command -v fzf >/dev/null 2>&1); then
  if test -f "${NIX_PROFILE}/share/fzf/completion.zsh"; then
    source "${NIX_PROFILE}/share/fzf/completion.zsh"
  else
    echo "Not found: ${NIX_PROFILE}/share/fzf/completion.zsh"
  fi

  if test -f "${NIX_PROFILE}/share/fzf/key-bindings.zsh"; then
    source "${NIX_PROFILE}/share/fzf/key-bindings.zsh"

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

    zle     -N   fzf-history-widget-rkm
    bindkey '^S' fzf-history-widget-rkm
    bindkey '^R' fzf-history-widget-rkm

    bind-fzf-git-helper "f" "fzf-git-file-helper"
    bind-fzf-git-helper "b" "fzf-git-branch-helper"
    bind-fzf-git-helper "t" "fzf-git-tag-helper"
    bind-fzf-git-helper "r" "fzf-git-remote-helper"
    bind-fzf-git-helper "h" "fzf-git-log-helper"
  else
    echo "Not found: ${NIX_PROFILE}/share/fzf/key-bindings.zsh"
  fi
fi

# Use fd (https://github.com/sharkdp/fd) instead of the default find
# command for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  fd --hidden --follow --exclude ".git" . "${1}"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type d --hidden --follow --exclude ".git" . "${1}"
}

if $(command -v nodenv >/dev/null 2>&1); then
  export PATH="${HOME}/.nodenv/shims:${PATH}"
  eval "$(nodenv init - zsh)"
fi

if $(command -v direnv >/dev/null 2>&1); then
  eval "$(direnv hook zsh)"
fi

if (command -v direnv >/dev/null 2>&1); then
  eval "$(fasd --init auto)"
fi

if test -f "${NIX_PROFILE}/share/zsh/plugins/syntax-highlighting/zsh-syntax-highlighting.plugin.zsh"; then
  source "${NIX_PROFILE}/share/zsh/plugins/syntax-highlighting/zsh-syntax-highlighting.plugin.zsh"
else
  echo "Not found: ${NIX_PROFILE}/share/zsh/plugins/syntax-highlighting/zsh-syntax-highlighting.plugin.zsh"
fi

# Local Variables:
# mode: shell-script
# End:
