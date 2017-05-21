# ~/.zsh_profile

[[ -f ~/.zshrc ]] && . ~/.zshrc

emulate sh -c 'source /etc/profile'

if isdarwin; then
  source ~/.nix-profile/etc/profile.d/nix.sh
  export ANDROID_HOME="${HOME}/Library/Android/sdk"
  export PATH="${PATH}:${ANDROID_HOME}/tools"
  export PATH="${PATH}:${ANDROID_HOME}/tools/bin"
  export PATH="${PATH}:${ANDROID_HOME}/platform-tools"
  export NIX_PATH="darwin=${HOME}/.nix-defexpr/darwin:darwin-config=${HOME}/.nixpkgs/darwin-configuration.nix:${NIX_PATH}"
fi
