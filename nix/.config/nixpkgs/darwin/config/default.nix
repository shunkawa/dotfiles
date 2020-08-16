args@{ config, lib, pkgs, ... }:

{
  imports = [
    ./environment.nix
    ./nixpkgs.nix
    ./nix-docker.nix
    <home-manager/nix-darwin>
  ];

  home-manager.users.eqyiel = import ../../home.nix;
  home-manager.useUserPackages = true;

  services.nix-daemon.enable = true;

  nix = {
    nixPath = [
      "darwin-config=/Users/${(builtins.getEnv "USER")}/.config/nixpkgs/darwin-configuration.nix"
      "darwin=/Users/${(builtins.getEnv "USER")}/.nix-defexpr/darwin"
      "home-manager=${import ../lib/home-manager.nix}"
      "nixpkgs=${import ../lib/nixpkgs.nix}"
    ];
  };

  services.local-modules.nix-darwin.spotlight = {
    # For disabling indexing in home, this doesn't work, because mdutil operates
    # on volumes, not folders.  You need to blacklist the home folder in the
    # "Spotlight > Privacy" preferences window.  Also blacklist the "Google
    # Drive stream" volume.
    enable = false;
    indexing = {
      volumes = {
        "/spotlight" = {
          enable = true;
          rebuild = true;
        };
      };
    };
  };

  # services.local-modules.nix-darwin.link-apps.enable = true;

  # WIP: Karabiner is a bit complicated due to installing a kernel extension.
  # Right now I'm just using brew cask, maybe look how they do it:
  # https://github.com/Homebrew/homebrew-cask/blob/master/Casks/karabiner-elements.rb

  # launchd.agents = {
  #   karabiner_console_user_server = {
  #     serviceConfig.KeepAlive = true;
  #     serviceConfig.Disabled = true;
  #     serviceConfig.ProgramArguments = [
  #       "${pkgs.local-packages.Karabiner-Elements}/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_console_user_server"
  #     ];
  #   };
  # };

  # launchd.daemons = {
  #   karabiner_grabber = {
  #     Disabled = false;
  #     KeepAlive = true;
  #     ProcessType = "Interactive";
  #     ProgramArguments = [
  #       "${pkgs.local-packages.Karabiner-Elements}/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_grabber"
  #     ];
  #   };
  # };

  launchd.user.agents = {
    # syncthing = {
    #   serviceConfig.ProgramArguments = [ "${pkgs.syncthing}/bin/syncthing" "-no-browser" "-no-restart" ];
    #   serviceConfig.EnvironmentVariables = {
    #     HOME = "/Users/${(builtins.getEnv "USER")}";
    #     STNOUPGRADE = "1"; # disable spammy automatic upgrade check
    #   };
    #   serviceConfig.KeepAlive = true;
    #   serviceConfig.ProcessType = "Background";
    #   serviceConfig.StandardOutPath = "/Users/${(builtins.getEnv "USER")}/Library/Logs/Syncthing.log";
    #   serviceConfig.StandardErrorPath = "/Users/${(builtins.getEnv "USER")}/Library/Logs/Syncthing-Errors.log";
    #   serviceConfig.LowPriorityIO = true;
    # };
  };

  # Recreate /run/current-system symlink after boot.
  services.activate-system.enable = true;

}
