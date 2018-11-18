{ config, lib, pkgs, ... }:

{
  imports = [
    ./environment.nix
    ./nixpkgs.nix
    ./nix-docker.nix
  ];

  services.nix-daemon.enable = false;

  nix = {
    nixPath = [
      "darwin=/Users/${(builtins.getEnv "USER")}/.nix-defexpr/darwin"
      "darwin-config=/Users/${(builtins.getEnv "USER")}/.config/nixpkgs/darwin-configuration.nix"
      "nixpkgs=${pkgs.callPackage ../lib/nixpkgs.nix {}}"
    ];
  };

  programs.zsh = {
    enable = true;
    enableFzfCompletion = true;
    enableFzfGit = true;
    enableFzfHistory = true;
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

  # Recreate /run/current-system symlink after boot.
  services.activate-system.enable = true;

}
