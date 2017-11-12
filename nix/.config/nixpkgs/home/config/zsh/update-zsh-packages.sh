#!/bin/sh

. ../../prefetch.sh

cat <<EOF | "${JQ}" -s add >| zsh-packages.json
  $(prefetch_git https://github.com/b4b4r07/enhancd.git enchancd)
  $(prefetch_git https://github.com/grml/grml-etc-core grml-etc-core)
  $(prefetch_git https://github.com/robbyrussell/oh-my-zsh.git oh-my-zsh)
  $(prefetch_git https://github.com/seebi/dircolors-solarized.git dircolors-solarized)
  $(prefetch_git https://github.com/sindresorhus/pure.git pure)
  $(prefetch_git https://github.com/sindresorhus/pure.git pure)
  $(prefetch_git https://github.com/spwhitt/nix-zsh-completions.git nix-zsh-completions)
  $(prefetch_git https://github.com/zsh-users/zsh-autosuggestions.git zsh-autosuggestions)
  $(prefetch_git https://github.com/zsh-users/zsh-completions.git zsh-completions)
  $(prefetch_git https://github.com/zsh-users/zsh-syntax-highlighting.git zsh-syntax-highlighting)
EOF
