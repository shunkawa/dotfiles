# Uncomment this and "zpof" at the bottom of this file to profile
# startup time.
# zmodload zsh/zprof

export NIX_PROFILE=${"${NIX_PROFILE}":-"$NIX_USER_PROFILE_DIR/profile"}
export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"
export LANGUAGE="en_US.UTF-8"

fpath=(
  "${HOME}/.config/zsh/functions"
  "${NIX_PROFILE}/share/zsh/site-functions"
  ${fpath[@]}
)

export PATH="${HOME}/.local/bin:${PATH}"

test -d "${HOME}/.cache/zsh" || mkdir -p "${HOME}/.cache/zsh"
COMPDUMPFILE="${HOME}/.cache/zsh/compdump"
export COMPDUMPFILE
touch "${COMPDUMPFILE}"

export NPM_CONFIG_INIT_AUTHOR_EMAIL="ruben@maher.fyi"
export NPM_CONFIG_INIT_AUTHOR_NAME="Ruben Maher"
export NPM_CONFIG_GIT_TAG_VERSION="false"
export NPM_CONFIG_CACHE="$HOME/.cache/npm"
# For per-directory or project configuration (private registries, etc), do
# something like this in .envrc:
# export NPM_CONFIG_USERCONFIG="$(pwd)/npmrc"

# Don't use x11-ssh-askpass
unset SSH_ASKPASS

export MSMTP_QUEUE="${HOME}/.cache/msmtp/queue"
test -d "${MSMTP_QUEUE}" || mkdir -p "${MSMTP_QUEUE}"
export MSMTP_LOG="${MSMTP_QUEUE}/log"
test -f "${MSMTP_LOG}" || touch "${MSMTP_LOG}"
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

export RKM_HISTORY_HIST_DIR="${HOME}/sync/history/zsh"
test -d "${RKM_HISTORY_HIST_DIR}" || mkdir -p "${RKM_HISTORY_HIST_DIR}"

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

# Uncomment this and "zmodload zsh/zprof" at the top of this file to profile
# startup time.
# zprof

# Local Variables:
# mode: shell-script
# End:
