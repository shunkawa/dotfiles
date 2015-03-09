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
