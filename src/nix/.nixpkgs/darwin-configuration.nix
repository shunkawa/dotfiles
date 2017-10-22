{ config, lib, pkgs, ... }:

let

  localPackages = (import ./pkgs/all-packages.nix) {
  inherit config lib pkgs;
};

# TODO: pin to a specific version of nixpkgs like this:
# nixpkgsMaster = import ((import <nixpkgs> { }).fetchFromGitHub {
#   owner = "NixOS";
#   repo = "nixpkgs";
#   rev = "fd22d671ecad983fbbbd92c4626204f09c9af8ff";
#   sha256 = "0pn8w5v2b7c82nr0zbb91bfzylr97hq3knwhlc8xhzibhp0d723a";
# }) { config = { }; };
# then, for example: nixpkgsMaster.pkgs.nodejs-8_x

in {
  imports = [
    ./pkgs/overrides.nix
  ];

  environment = {
    systemPackages = with pkgs; [
      aspell
      aspellDicts.en
      bind
      coreutils
      curl
      direnv
      (lib.hiPrio localPackages.emacs-git)
      fd
      ffmpeg
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
      localPackages.nodePackages.reddit-oauth-helper
      mpv
      msmtp
      mu
      nix-prefetch-scripts
      nix-repl
      nixops
      openssh
      pass
      pwgen
      reattach-to-user-namespace
      ripgrep
      rsync
      sift
      silver-searcher
      socat
      stow
      syncthing
      tmux
      tree
      unrar
      unzip
      wget
      which

      purs

      postgresql96
      apacheHttpd
      awsebcli
      flow
      jekyll
      lftp
      localPackages.fontcustom
      localPackages.nodePackages."@jasondibenedetto/plop"
      localPackages.nodePackages.eslint-cli
      localPackages.nodePackages.flow-typed
      localPackages.nodePackages.grunt-cli
      localPackages.nodePackages.imapnotify
      localPackages.nodePackages.react-native-cli
      localPackages.nodePackages.commitizen
      localPackages.nodePackages.cz-conventional-changelog
      localPackages.nodePackages.tern
      localPackages.nodePackages.wscat
      localPackages.nodePackages.yarn
      localPackages.scss-lint
      nodePackages_6_x.node2nix
      nodejs-8_x
      # php
      # php70Packages.composer
      # php70Packages.phpcbf
      # php70Packages.phpcs
      watchman
    ];

    variables = {
      # If you don't do this, Emacs will throw errors like this because it can't
      # find the dictionary files:
      # Starting new Ispell process /run/current-system/sw/bin/aspell with english dictionary...
      # Error enabling Flyspell mode:
      # (Error: The file "/nix/store/ ... /lib/aspell/english" can not be opened for reading.)
      ASPELL_CONF = "data-dir /run/current-system/sw/lib/aspell";
    };

    shellAliases = {
      emacs = "${localPackages.emacs-git}/Applications/Emacs.app/Contents/MacOS/Emacs";
    };

    pathsToLink = [
      "/lib"         # Necessary for apsell thing
      "/share/emacs" # Necessary for emacs support files (mu4e)
    ];
 
    etc."ssl/certs/ca-certificates.crt".source =
      "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";

    # github.com/facebook/react-native/issues/9309#issuecomment-238966924
    etc."sysctl.conf" = {
      text = ''
        kern.maxfiles=10485760
        kern.maxfilesperproc=1048576
      '';
    };
  };

  programs.zsh = {
    enable = true;
    enableFzfCompletion = true;
    enableFzfGit = true;
    enableFzfHistory = true;
  };

  programs.nix-index.enable = true;

  nix.nixPath = [
    "darwin=/Users/rkm/.nix-defexpr/darwin"
    "darwin-config=/Users/rkm/.nixpkgs/darwin-configuration.nix"
    "nixpkgs=/Users/rkm/.nix-defexpr/nixpkgs"
  ];

  nixpkgs = {
    config = {
      allowBroken = true;
      allowUnfree = true;
      packageOverrides = pkgs: {
        mpv = pkgs.mpv.override ({ drmSupport = false; vaapiSupport = false; });

        syncthing = with pkgs; stdenv.mkDerivation rec {
          name = "syncthing";
          version = "0.14.38";

          src = fetchurl {
            url = "https://github.com/syncthing/syncthing/releases/download/v${version}/syncthing-macosx-amd64-v${version}.tar.gz";
            sha256 = "0k7g4cxkl6x5ic6psxc4fjgcq50w8l11iy5hzv1zq3rs8wg80hnb";
          };

          buildInputs = [ gnutar ];

          dontBuild = true;

          installPhase = ''
            mkdir -p "$out/tmp";
            tar xf ${src} -C "$out/tmp" --strip-components 1
            mkdir -p "$out/bin";
            mv "$out/tmp/syncthing" "$out/bin"
            rm -rf "$out/tmp"
          '';
        };
      };
    };
  };

  launchd.user.agents.syncthing = {
    serviceConfig.ProgramArguments = [ "${pkgs.syncthing}/bin/syncthing" "-no-browser" "-no-restart" ];
    serviceConfig.EnvironmentVariables = {
      HOME = "/Users/rkm";
      STNOUPGRADE = "1"; # disable spammy automatic upgrade check
    };
    serviceConfig.KeepAlive = true;
    serviceConfig.ProcessType = "Background";
    serviceConfig.StandardOutPath = "/Users/rkm/Library/Logs/Syncthing.log";
    serviceConfig.StandardErrorPath = "/Users/rkm/Library/Logs/Syncthing-Errors.log";
    serviceConfig.LowPriorityIO = true;
  };

  # services.httpd.enable = true;

  # Recreate /run/current-system symlink after boot.
  services.activate-system.enable = true;

  system.stateVersion = 2;
}
