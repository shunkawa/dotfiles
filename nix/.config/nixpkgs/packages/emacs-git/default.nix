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
  version = "26.1.92";
  versionModifier = "-git";
  src = fetchgit {
    url = "git://git.sv.gnu.org/emacs.git";
    sha256 = "0v6nrmf0viw6ahf8s090hwpsrf6gjpi37r842ikjcsakfxys9dmc";
    rev = "4c6d17afe1251ddc7f5113991d8e914571f76ecf";
  };
  patches = [
    ./revert-9344612d3cd164317170b6189ec43175757e4231.patch
    ./clean-env.patch
    ./tramp-detect-wrapped-gvfsd.patch
  ];
})
