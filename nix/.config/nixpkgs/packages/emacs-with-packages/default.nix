{ emacs, emacsPackagesNgGen, local-packages, fetchFromGitHub }:

let
  emacsPackagesNg = emacsPackagesNgGen emacs;

  emacsPackageOverrides = (self: super: {
    inherit emacs;
    org-jira = (self.melpaPackages.org-jira.overrideAttrs (attrs: {
      src = fetchFromGitHub {
        owner = "ahungry";
        repo = "org-jira";
        rev = "d1d2ff6155c6259a066110ed13d1850143618f7b";
        sha256 = "044yl2k9ny0m5nyw0k8qhhmalxq3j88i3lhcc5jv1gmymcwaplff";
      };
    }));
  });

  mkEmacsPackages = (emacsPackages:
    (with emacsPackages; [
      org-jira
    ]) ++
    (with emacsPackages.elpaPackages; [
      rainbow-mode
      sql-indent
    ]) ++
    (with emacsPackages.melpaPackages; [
      adoc-mode
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
      company-nixos-options
      company-posframe
      counsel
      counsel-projectile
      dash
      diminish
      direnv
      dtrt-indent
      emojify
      eslint-fix
      expand-region
      fasd
      flow-minor-mode
      flycheck
      flycheck-flow
      geben
      gist
      go-mode
      google-c-style
      google-translate
      graphql-mode
      groovy-mode
      haskell-mode
      highlight-indentation
      ibuffer-projectile
      ivy
      ivy-posframe
      js2-mode
      json-mode
      key-chord
      legalese
      lsp-java
      lsp-mode
      lsp-ui
      magit
      markdown-mode
      multiple-cursors
      nix-buffer
      nix-mode
      nixos-options
      no-littering
      nodejs-repl
      omnisharp
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
      tide
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
      local-packages.mu
    ]);
in ((emacsPackagesNg.overrideScope' emacsPackageOverrides).emacsWithPackages
  mkEmacsPackages)
