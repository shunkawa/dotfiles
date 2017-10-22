# ~/.zprofile

[[ -f /etc/zprofile ]] && . /etc/zprofile

[[ -f ~/.zshrc ]] && . ~/.zshrc

if isdarwin; then
  source ~/.nix-profile/etc/profile.d/nix.sh
fi
