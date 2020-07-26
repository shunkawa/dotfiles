{ config, lib, pkgs, ... }:

let

in {
  fonts = {
    enableFontDir = true;
    fonts = with pkgs; [
      dejavu_fonts
    ];
  };

  system.defaults.dock.autohide = true;

  services.local-modules.nix-darwin.keyboard = {
    enable = true;
    devices = {
      # Device ID of the internal keyboard only (check the output of
      # `system_profiler SPUSBDataType` or find it in Apple menu →
      # System Report → Hardware → USB)
      "0x027e" = {
        "Keyboard Left Function (fn)" = "Keyboard LeftControl";
        "Keyboard Left GUI" = "Keyboard LeftAlt";
        "Keyboard LeftAlt" = "Keyboard Left GUI";
        "Keyboard RightAlt" = "Keyboard RightControl";
        "Keyboard Right GUI" = "Keyboard RightAlt";
        "Keyboard Caps Lock" = "Keyboard F24";
      };
    };
  };

  programs.zsh.enable = true;

  environment = {
    systemPackages =  with pkgs; [
      local-packages.mac-apps.Alfred
      local-packages.mac-apps.Anki
      local-packages.mac-apps.Contexts
      local-packages.mac-apps.Docker
      local-packages.mac-apps.GIMP
      local-packages.mac-apps.ImageOptim
      local-packages.mac-apps.SequelPro
      local-packages.mac-apps.Sketch
      local-packages.mac-apps.Spectacle
      local-packages.mac-apps.iTerm2
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
