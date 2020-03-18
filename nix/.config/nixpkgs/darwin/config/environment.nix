{ config, lib, pkgs, ... }:

{
  fonts = {
    enableFontDir = true;
    fonts = with pkgs; [
      dejavu_fonts
    ];
  };

  system.defaults.dock.autohide = true;

  environment = {
    systemPackages = with pkgs; [
      aspell
      aspellDicts.en
      aspellDicts.en-computers
      aspellDicts.en-science
      iterm2
      local-packages.Alfred
      local-packages.Anki
      local-packages.Contexts
      local-packages.Docker
      local-packages.GIMP
      local-packages.ImageOptim
      local-packages.SequelPro
      local-packages.Sketch
      local-packages.Spectacle
      qemu
      syncthing
    ];

    variables = {
      # If you don't do this, Emacs will throw errors like this because it can't
      # find the dictionary files:
      # Starting new Ispell process /run/current-system/sw/bin/aspell with english dictionary...
      # Error enabling Flyspell mode:
      # (Error: The file "/nix/store/ ... /lib/aspell/english" can not be opened for reading.)
      ASPELL_CONF = "data-dir /run/current-system/sw/lib/aspell";
    };

    pathsToLink = [
      "/lib"           # for aspell
      "/share/emacs"   # Necessary for emacs support files (mu4e)
    ];

    etc = {
      # github.com/facebook/react-native/issues/9309#issuecomment-238966924
      "sysctl.conf" = {
        text = ''
          kern.maxfiles=10485760
          kern.maxfilesperproc=1048576
        '';
      };
    };
  };

  launchd.daemons."maxfiles" = {
    serviceConfig.Label = "limit.maxfiles";
    serviceConfig.RunAtLoad = true;
    serviceConfig.ProgramArguments = [
      "launchctl"
      "limit"
      "maxfiles"
      "65536"
      "524288"
    ];
  };
}
