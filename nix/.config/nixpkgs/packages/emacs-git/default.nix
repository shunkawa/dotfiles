{ stdenv, fetchgit, emacs }:

# nix-prefetch-git git://git.sv.gnu.org/emacs.git --rev HEAD

stdenv.lib.overrideDerivation
  (emacs.override { srcRepo = true; }) (attrs: rec {
  name = "emacs-${version}${versionModifier}";
  version = "27.0.50";
  versionModifier = "-git";
  src = fetchgit {
    url = "git://git.sv.gnu.org/emacs.git";
    sha256 = "0xgf63l4rlrabaxy6c2qxi76p3mg460c49b23g1rswigw2sc7c9f";
    rev = "1cdd0e8cd801aa1d6f04ab4d8e6097a46af8c951";
  };
  patches = [];
})
