#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc
if [ -e /Users/rkm/.nix-profile/etc/profile.d/nix.sh ]; then . /Users/rkm/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer


[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
