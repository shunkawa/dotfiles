{ emacsPackagesNg, mu }:

# TODO:
# Figure out how to include packages that aren't in nixpkgs.  I think there is
# still a use case for having submodules in ~/.emacs.d (for stuff that I want to
# contribute to) but for others that just aren't available on melpa yet I would
# like to have them here (for example, flow-js2-mode).

(emacsPackagesNg.emacsWithPackages
  (emacsPackages:
    (with emacsPackages.elpaPackages; [
      rainbow-mode
    ]) ++
    (with emacsPackages.melpaPackages; [
      aggressive-indent
      alert
      atomic-chrome
      avy
      beacon
      bind-key
      buffer-move
      calfw
      calfw-org
      circe
      column-enforce-mode
      company
      company-emoji
      company-lsp
      counsel
      counsel-projectile
      dash
      diminish
      direnv
      dtrt-indent
      emojify
      eslint-fix
      expand-region
      flow-minor-mode
      flycheck
      flycheck-flow
      gist
      google-c-style
      google-translate
      groovy-mode
      haskell-mode
      highlight-indentation
      ivy
      js2-mode
      json-mode
      key-chord
      legalese
      lsp-java
      lsp-javascript-flow
      lsp-mode
      lsp-ui
      magit
      markdown-mode
      multiple-cursors
      nix-buffer
      no-littering
      nodejs-repl
      org-caldav
      org-cliplink
      org-download
      org-mime
      ox-gfm
      pass
      php-mode
      pkgbuild-mode
      prettier-js
      projectile
      rjsx-mode
      s
      scss-mode
      skewer-mode
      smartparens
      smex
      solarized-theme
      swift-mode
      swiper
      tiny
      unfill
      use-package
      use-package-chords
      visual-fill-column
      web-mode
      ws-butler
      yaml-mode
      yasnippet
    ]) ++ (with emacsPackages.orgPackages; [
      org-plus-contrib
    ]) ++ [
      mu
    ]))
