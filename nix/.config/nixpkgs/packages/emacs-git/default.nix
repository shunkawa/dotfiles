{ stdenv, fetchgit, emacs }:

# Check available tags:
# http://git.savannah.gnu.org/cgit/emacs.git/refs/tags
#
(stdenv.lib.overrideDerivation (emacs.override { srcRepo = true; })) (attrs: rec {
  name = "emacs-${version}${versionModifier}";
  version = "27";
  versionModifier = ".1";
  src = fetchgit {
    inherit ((builtins.fromJSON (builtins.readFile ./versions.json)).emacs) rev sha256 url;
  };
  patches = [ ]; # override the parent definition
})
