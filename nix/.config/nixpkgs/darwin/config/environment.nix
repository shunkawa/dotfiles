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
      local-packages.Anki
      local-packages.Docker
      local-packages.GIMP
      local-packages.Sketch
      local-packages.Spectacle
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
      "ssl/certs/ca-certificates.crt".source =
        "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";

      # github.com/facebook/react-native/issues/9309#issuecomment-238966924
      "sysctl.conf" = {
        text = ''
          kern.maxfiles=10485760
          kern.maxfilesperproc=1048576
        '';
      };
    };
  };
}
