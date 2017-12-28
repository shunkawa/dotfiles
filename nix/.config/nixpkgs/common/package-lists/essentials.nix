{ pkgs }:

with pkgs; [
  (lib.lowPrio inetutils) # prefer pkgs.whois over whois from pkgs.inetutils
  aspell
  aspellDicts.en
  bind # provides dig
  bmon
  coreutils
  curl
  elfutils # provides eu-readelf
  fatresize
  fdupes
  ffmpeg
  file
  findutils
  fzf
  gcc
  gitAndTools.gitFull
  gnugrep
  gnumake
  gnupg22
  gnused
  gnutls
  htop
  imagemagick
  jq
  libidn
  lsof
  mercurialFull
  mpd
  msmtp
  mu
  ncdu
  nethogs
  nix-prefetch-git
  nix-prefetch-scripts
  nix-repl
  nixops
  nmap
  openssh
  openssl
  p7zip
  pcsctools
  procmail
  psmisc # provides fuser, killall, pstree
  pwgen
  python
  ripgrep
  rsync
  sift
  silver-searcher
  smartmontools
  socat
  stow
  su
  tcptrack
  texlive.combined.scheme-full
  tmux
  tree
  unrar
  unzip
  usbutils
  vim
  wget
  which
  whois # better than the one from inetutils
  xdg-user-dirs
  xdg_utils
  xsv # csv toolkit
  zip
]
