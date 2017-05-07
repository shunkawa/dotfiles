{ config, lib, pkgs, ... }:

let

localPackages = (import ./pkgs/all-packages.nix) {
    inherit config lib pkgs;
};

in {
  imports = [
    ./pkgs/overrides.nix
    ./httpd.nix
  ];

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    aspell
    aspellDicts.en
    bind
    coreutils
    curl
    direnv
    emacs25
    file
    findutils
    fzf
    gitAndTools.git-crypt
    gitAndTools.gitFull
    gnumake
    gnupg
    gnused
    gnutar
    haskellPackages.ShellCheck
    htop
    isync
    msmtp
    nix-repl
    nixops
    notmuch
    openssh
    pass
    pwgen
    reattach-to-user-namespace
    rsync
    silver-searcher
    stow
    syncthing
    tmux
    tree
    unrar
    unzip
    wget
    which

    apacheHttpd
    jekyll
    lftp
    localPackages.nodePackages."@jasondibenedetto/plop"
    localPackages.nodePackages.eslint-cli
    localPackages.nodePackages.grunt-cli
    localPackages.nodePackages.imapnotify
    localPackages.nodePackages.react-native-cli
    localPackages.nodePackages.tern
    localPackages.nodePackages.webpack
    localPackages.nodePackages.wscat
    localPackages.nodePackages.yarn
    localPackages.scss-lint
    nodePackages_6_x.node2nix
    nodejs-7_x
    php
    php70Packages.composer
    php70Packages.phpcbf
    php70Packages.phpcs
    watchman
  ];

  environment.shellAliases = {
    emacs = "$(dirname $(dirname $(readlink -f $(which Emacs))))/Applications/Emacs.app/Contents/MacOS/Emacs";
  };

  # Create /etc/bashrc that loads the nix-darwin environment.
  # programs.bash.enable = true;

  programs.zsh = {
    enable = true;
    enableFzfCompletion = true;
    enableFzfGit = true;
    enableFzfHistory = true;
  };

  nixpkgs.config.allowUnfree = true;

  # github.com/facebook/react-native/issues/9309#issuecomment-238966924
  environment.etc."sysctl.conf" = {
    text = ''
      kern.maxfiles=10485760
      kern.maxfilesperproc=1048576
    '';
  };

  environment.extraOutputsToInstall = [ "man" "dev" "devdoc" ];

  nixpkgs.config.packageOverrides = pkgs: {    
    syncthing = with pkgs; stdenv.mkDerivation rec {
      name = "syncthing";
      version = "0.14.25";

      src = fetchurl {
        url = "https://github.com/syncthing/syncthing/releases/download/v${version}/syncthing-macosx-amd64-v${version}.tar.gz";
        sha256 = "19inj8xzhfd7pkqpp9vrvx3nrykvjsysbd9p4kv4l73lnxwriv23";
      };

      buildInputs = [ gnutar ];

      dontBuild = true;

      installPhase = ''
        mkdir -p "$out/tmp";
        tar xf ${src} -C "$out/tmp" --strip-components 1
        ls -lha $out/tmp
        mkdir -p "$out/bin";
        mv "$out/tmp/syncthing" "$out/bin"
        rm -rf "$out/tmp"
      '';
    };
  };

  launchd.user.agents.syncthing = {
    serviceConfig.ProgramArguments = [ "${pkgs.syncthing}/bin/syncthing" "-no-browser" "-no-restart" ];
    serviceConfig.EnvironmentVariables = {
      HOME = "/Users/rkm";
    };
    serviceConfig.KeepAlive = true;
    serviceConfig.ProcessType = "Background";
    serviceConfig.StandardOutPath = "/Users/rkm/Library/Logs/Syncthing.log";
    serviceConfig.StandardErrorPath = "/Users/rkm/Library/Logs/Syncthing-Errors.log";
    serviceConfig.LowPriorityIO = true;
  };

  services.httpd.enable = true;

  # Recreate /run/current-system symlink after boot.
  services.activate-system.enable = true;
}
