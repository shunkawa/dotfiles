{ config, lib, pkgs, ... }:

{
  imports = [
    ./environment.nix
    ./nixpkgs.nix
    ./nix-docker.nix
  ];

  nix = {
    nixPath = [
      "darwin=/Users/rkm/.nix-defexpr/darwin"
      "darwin-config=/Users/rkm/.config/nixpkgs/darwin-configuration.nix"
      "nixpkgs=/Users/rkm/.nix-defexpr/nixpkgs-darwin"
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
