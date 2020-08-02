{ config, lib, pkgs, ... }:
let

in
{
  fonts = {
    enableFontDir = true;
    fonts = with pkgs; [
      dejavu_fonts
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      noto-fonts-extra
    ];
  };

  system.defaults.dock.autohide = true;
  system.defaults.dock.showhidden = true;
  system.defaults.dock.show-recents = false;
  system.defaults.dock.static-only = true;

  system.defaults.finder.AppleShowAllExtensions = true;
  system.defaults.finder.QuitMenuItem = true;
  system.defaults.finder.FXEnableExtensionChangeWarning = false;

  # Enable tap to click
  system.defaults.trackpad.Clicking = true;
  system.defaults.trackpad.TrackpadThreeFingerDrag = true;

  # defaults read NSGlobalDomain prints a bunch of stuff

  # Enable tab completion for all menu bar items
  system.defaults.NSGlobalDomain.AppleKeyboardUIMode = 3;
  system.defaults.NSGlobalDomain.ApplePressAndHoldEnabled = false;
  system.defaults.NSGlobalDomain.InitialKeyRepeat = 10;
  system.defaults.NSGlobalDomain.KeyRepeat = 1;
  system.defaults.NSGlobalDomain.NSAutomaticCapitalizationEnabled = false;
  system.defaults.NSGlobalDomain.NSAutomaticDashSubstitutionEnabled = false;
  system.defaults.NSGlobalDomain.NSAutomaticPeriodSubstitutionEnabled = false;
  system.defaults.NSGlobalDomain.NSAutomaticQuoteSubstitutionEnabled = false;
  system.defaults.NSGlobalDomain.NSAutomaticSpellingCorrectionEnabled = false;
  #system.defaults.NSGlobalDomain.NSAutomaticTextCompletionEnabled = false;
  #system.defaults.NSGlobalDomain.WebAutomaticSpellingCorrectionEnabled = false;
  #system.defaults.NSGlobalDomain.AppleLocale = "en_US";
  #system.defaults.NSGlobalDomain.AppleLanguages = [ "en" "ja" ];
  # system.defaults.NSGlobalDomain.NSUserDictionaryReplacementItems = [
  #   # The default:
  #   # {
  #   #   on = 1;
  #   #   replace = omw;
  #   #   with = "On my way!";
  #   # }
  # ];
  #system.defaults.NSGlobalDomain.NSLinguisticDataAssetsRequested = [ "en" "ja" ];

  # Enable the full save dialog always
  system.defaults.NSGlobalDomain.NSNavPanelExpandedStateForSaveMode = true;
  system.defaults.NSGlobalDomain.NSNavPanelExpandedStateForSaveMode2 = true;

  # Hide the global menu bar
  system.defaults.NSGlobalDomain._HIHideMenuBar = true;

  services.skhd.enable = true;
  services.skhd.skhdConfig =
    let
      skhd = "${pkgs.skhd}/bin/skhd";
    in
    ''
      # Caps lock is bound to "Keyboard Left Function (fn)" by hidutil.
      fn - a:       ${skhd} -k "hyper - a"
      fn - b:       ${skhd} -k "hyper - b"
      fn - c:       ${skhd} -k "hyper - c"
      fn - d:       ${skhd} -k "hyper - d"
      fn - e:       ${skhd} -k "hyper - e"
      fn - f:       ${skhd} -k "hyper - f"
      fn - g:       ${skhd} -k "hyper - g"
      fn - h:       ${skhd} -k "hyper - h"
      fn - i:       ${skhd} -k "hyper - i"
      fn - j:       ${skhd} -k "hyper - j"
      fn - k:       ${skhd} -k "hyper - k"
      fn - l:       ${skhd} -k "hyper - l"
      fn - m:       ${skhd} -k "hyper - m"
      fn - n [
         "firefox": ${skhd} -k "ctrl - pagedown"
         "chrome" : ${skhd} -k "ctrl - pagedown"
         *        : ${skhd} -k "hyper - n"
      ]
      fn - o:       ${skhd} -k "hyper - o"
      fn - p [
         "firefox": ${skhd} -k "ctrl - pageup"
         "chrome" : ${skhd} -k "ctrl - pageup"
         *        : ${skhd} -k "hyper - p"
      ]
      fn - p:       ${skhd} -k "hyper - p"
      fn - q:       ${skhd} -k "hyper - q"
      fn - r:       ${skhd} -k "hyper - r"
      fn - s:       ${skhd} -k "hyper - s"
      fn - space:   ${skhd} -k "hyper - space"
      fn - t:       ${skhd} -k "hyper - t"
      fn - u:       ${skhd} -k "hyper - u"
      fn - v:       ${skhd} -k "hyper - v"
      fn - w:       ${skhd} -k "hyper - w"
      fn - x:       ${skhd} -k "hyper - x"
      fn - y:       ${skhd} -k "hyper - y"
      fn - z:       ${skhd} -k "hyper - z"
    '';

  system.keyboard.enableKeyMapping = true;
  system.keyboard.mappings = {
    # Bind Caps Lock to Left Function for all other keyboards.
    "Keyboard Caps Lock" = "Keyboard Left Function (fn)";
    # For the built-in MacBook keyboard, change the modifiers to match a
    # traditional keyboard layout.
    "0x27e" = {
      "Keyboard Caps Lock" = "Keyboard Left Function (fn)";
      "Keyboard Left Alt" = "Keyboard Left GUI";
      "Keyboard Left Function (fn)" = "Keyboard Left Control";
      "Keyboard Left GUI" = "Keyboard Left Alt";
      "Keyboard Right Alt" = "Keyboard Right Control";
      "Keyboard Right GUI" = "Keyboard Right Alt";
    };
  };

  programs.zsh.enable = true;

  environment = {
    systemPackages = with pkgs; [
      local-packages.mac-apps.Alfred
      local-packages.mac-apps.Anki
      local-packages.mac-apps.Chrome
      local-packages.mac-apps.Chromium
      local-packages.mac-apps.Contexts
      local-packages.mac-apps.Docker
      local-packages.mac-apps.Firefox
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
