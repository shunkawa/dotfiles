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
    sha256 = "1p8k58k4zwkngyrykq5hrdnz1gdy2a1fnhg07yzq1san1w1hc74k";
    rev = "b10464c6f92f4102e1c4a055c2683c1ab1b98bc6";
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
