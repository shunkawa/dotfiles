#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '

# Don't put duplicate lines in the history. See bash(1) for more options.
# ignoredups - causes lines matching the previous history entry to not be
#     saved
# ignorespace - lines which begin with a space character are not saved in the
#     history list
# ignoreboth - shorthand for ignorespace and ignoredups
# erasedups - causes all previous lines matching the current line to be
#     removed from the history list before that line is saved
export HISTCONTROL=ignoreboth:erasedups

HISTFILE=~/.bash_history
HISTSIZE=100000
HISTFILESIZE=100000

source ${HOME}/.config/bash_completion.d/tmux

# append to the history file, don't overwrite it
shopt -s histappend

gpg_p=$(pgrep gpg-agent)

if [[ $? -eq 1 ]]; then
    eval $(gpg-agent --daemon --enable-ssh-support --sh)
fi
SSH_AUTH_SOCK="/Users/rkm/.gnupg/S.gpg-agent.ssh"

NPM_PACKAGES="$HOME/.npm-packages"
PATH="/usr/local/opt/coreutils/libexec/gnubin:${PATH}"
PATH="${HOME}/.local/bin:${PATH}"
PATH="${NPM_PACKAGES}/bin:${PATH}"
PATH="${HOME}/Library/Python/2.7/bin:${PATH}"
PATH="$(brew --prefix php54):${PATH}"

MANPATH="/usr/local/opt/coreutils/libexec/gnuman:${MANPATH}"
MANPATH="${NPM_PACKAGES}/share/man:${MANPATH}"
NODE_PATH="$NPM_PACKAGES/lib/node_modules:$NODE_PATH"

NVM_DIR=~/.nvm
. $(brew --prefix nvm)/nvm.sh

PYTHONPATH="$HOME/.local/share/python"

. "${HOME}/.nix-profile/etc/profile.d/nix.sh"
NIX_PATH="/nix/var/nix/profiles/per-user/rkm/channels/nixos"

function ec2() {
  export AWS_ACCESS_KEY="$(pass mango/aws/$1/access-key-id | head -n 1)"
  export AWS_SECRET_KEY="$(pass mango/aws/$1/secret-access-key | head -n 1)"
  export EC2_URL="https://ec2.ap-southeast-2.amazonaws.com"
  # for nixops
  export EC2_ACCESS_KEY=$AWS_ACCESS_KEY
  export EC2_SECRET_KEY=$AWS_SECRET_KEY
}

eval "$(direnv hook bash)"
