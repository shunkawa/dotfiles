import
  (builtins.fetchTarball {
    name = "emacs-overlay-2020-10-13";
    url = https://github.com/nix-community/emacs-overlay/archive/57eb4be3bf3f9d982c92eca57c5069b4404b9907.tar.gz;
    sha256 = "0a9ricfnk642gv52yb0y5mch7cap7w81ybzndl9pks97d6gzadpv";
  })
