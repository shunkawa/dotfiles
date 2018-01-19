{ emacs25PackagesNg, mu }:

# TODO:
# Figure out how to include packages that aren't in nixpkgs.  I think there is
# still a use case for having submodules in ~/.emacs.d (for stuff that I want to
# contribute to) but for others that just aren't available on melpa yet I would
# like to have them here (for example, flow-js2-mode).

(emacs25PackagesNg.emacsWithPackages (epkgs: [
  mu
  epkgs.elpaPackages.rainbow-mode
  epkgs.melpaPackages.aggressive-indent
  epkgs.melpaPackages.alert
  epkgs.melpaPackages.atomic-chrome
  epkgs.melpaPackages.auth-password-store
  epkgs.melpaPackages.avy
  epkgs.melpaPackages.beacon
  epkgs.melpaPackages.bind-key
  epkgs.melpaPackages.buffer-move
  epkgs.melpaPackages.calfw
  epkgs.melpaPackages.calfw-org
  epkgs.melpaPackages.circe
  epkgs.melpaPackages.column-enforce-mode
  epkgs.melpaPackages.company
  epkgs.melpaPackages.company-emoji
  epkgs.melpaPackages.company-flow
  epkgs.melpaPackages.company-tern
  epkgs.melpaPackages.counsel
  epkgs.melpaPackages.counsel-projectile
  epkgs.melpaPackages.dash
  epkgs.melpaPackages.diminish
  epkgs.melpaPackages.direnv
  epkgs.melpaPackages.dtrt-indent
  epkgs.melpaPackages.emojify
  epkgs.melpaPackages.eslint-fix
  epkgs.melpaPackages.expand-region
  epkgs.melpaPackages.flow-minor-mode
  epkgs.melpaPackages.flycheck
  epkgs.melpaPackages.flycheck-flow
  epkgs.melpaPackages.gist
  epkgs.melpaPackages.google-c-style
  epkgs.melpaPackages.highlight-indentation
  epkgs.melpaPackages.ivy
  epkgs.melpaPackages.js2-mode
  epkgs.melpaPackages.json-mode
  epkgs.melpaPackages.key-chord
  epkgs.melpaPackages.legalese
  epkgs.melpaPackages.magit
  epkgs.melpaPackages.markdown-mode
  epkgs.melpaPackages.multiple-cursors
  epkgs.melpaPackages.nix-buffer
  epkgs.melpaPackages.no-littering
  epkgs.melpaPackages.nodejs-repl
  epkgs.melpaPackages.org-caldav
  epkgs.melpaPackages.org-cliplink
  epkgs.melpaPackages.org-download
  epkgs.melpaPackages.org-mime
  epkgs.melpaPackages.ox-gfm
  epkgs.melpaPackages.pass
  epkgs.melpaPackages.php-mode
  epkgs.melpaPackages.pkgbuild-mode
  epkgs.melpaPackages.prettier-js
  epkgs.melpaPackages.projectile
  epkgs.melpaPackages.rjsx-mode
  epkgs.melpaPackages.s
  epkgs.melpaPackages.scss-mode
  epkgs.melpaPackages.skewer-mode
  epkgs.melpaPackages.smartparens
  epkgs.melpaPackages.smex
  epkgs.melpaPackages.solarized-theme
  epkgs.melpaPackages.sql-indent
  epkgs.melpaPackages.swift-mode
  epkgs.melpaPackages.swiper
  epkgs.melpaPackages.tern
  epkgs.melpaPackages.tiny
  epkgs.melpaPackages.unfill
  epkgs.melpaPackages.use-package
  epkgs.melpaPackages.visual-fill-column
  epkgs.melpaPackages.web-mode
  epkgs.melpaPackages.ws-butler
  epkgs.melpaPackages.yaml-mode
  epkgs.melpaPackages.yasnippet
  epkgs.orgPackages.org-plus-contrib
]))
