{ stdenv, fetchgit, emacs }:

# nix-prefetch-git git://git.sv.gnu.org/emacs.git --rev emacs-26.1.92
#
# Check available tags:
# http://git.savannah.gnu.org/cgit/emacs.git/refs/tags
#
# Create revert patch for this commit for color emoji support on macOS:
# git revert 9344612d3cd164317170b6189ec43175757e4231
# git show --patch HEAD > revert-9344612d3cd164317170b6189ec43175757e4231.patch
(stdenv.lib.overrideDerivation (emacs.override { srcRepo = true; })) (attrs: rec {
  name = "emacs-${version}${versionModifier}";
  version = "27.0";
  versionModifier = ".50";
  src = fetchgit {
    url = "git://git.sv.gnu.org/emacs.git";
    sha256 = "1qxil0112sjr338igznzqxlj6860nmsy1ns7jki0kf7yrv3bx1hm";
    rev = "5715eb94e90b33ace59dd4c4ccb6e2122bc6db72";
  };
  patches = [
    # This patch reverts the infamous "don't use a color bitmap font until it is
    # supported on free platforms" commit.  It is needed for 26x but already
    # applied in master.
    # https://news.ycombinator.com/item?id=13011185
    # ./revert-9344612d3cd164317170b6189ec43175757e4231.patch
    # ./clean-env.patch
    # ./tramp-detect-wrapped-gvfsd.patch
  ];
})
