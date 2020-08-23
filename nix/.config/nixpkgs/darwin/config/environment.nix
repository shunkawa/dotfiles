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

  system.activationScripts.postActivation.text = ''
    # Disable the sound effects on boot
    sudo nvram SystemAudioVolume=" "
  '';

  # TODO: figure out how to do this
  # defaults write com.apple.systemsound "com.apple.sound.uiaudio.enabled" -int 0

  # TODO: even solid colors is a meme,
  # open /System/Library/Desktop\ Pictures/Solid\ Colors/Turquoise\ Green.png

  system.defaults.dock.autohide = true;
  system.defaults.dock.showhidden = true;
  system.defaults.dock.show-recents = false;
  system.defaults.dock.static-only = true;

  system.defaults.screencapture.location = "${builtins.getEnv "HOME"}/Desktop";

  system.defaults.finder.AppleShowAllExtensions = true;
  system.defaults.finder.QuitMenuItem = true;
  system.defaults.finder.FXEnableExtensionChangeWarning = false;

  # Enable tap to click
  system.defaults.trackpad.Clicking = true;
  system.defaults.trackpad.TrackpadThreeFingerDrag = true;

  # defaults read prints a bunch of stuff

  # Enable tab completion for all menu bar items
  system.defaults.NSGlobalDomain.AppleKeyboardUIMode = 3;

  # Disable the alternate character selection prompt that shows up when holding
  # a key down.
  system.defaults.NSGlobalDomain.ApplePressAndHoldEnabled = false;

  system.defaults.NSGlobalDomain.InitialKeyRepeat = 25;
  system.defaults.NSGlobalDomain.KeyRepeat = 6;
  system.defaults.NSGlobalDomain.NSAutomaticCapitalizationEnabled = false;
  system.defaults.NSGlobalDomain.NSAutomaticDashSubstitutionEnabled = false;
  system.defaults.NSGlobalDomain.NSAutomaticPeriodSubstitutionEnabled = false;
  system.defaults.NSGlobalDomain.NSAutomaticQuoteSubstitutionEnabled = false;
  system.defaults.NSGlobalDomain.NSAutomaticSpellingCorrectionEnabled = false;

  # These don't exist in nix-darwin yet
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
  # TODO there is an equivalent thing for print https://github.com/mathiasbynens/dotfiles/blob/c886e139233320e29fd882960ba3dd388d57afd7/.macos#L55-L57

  # Hide the global menu bar
  system.defaults.NSGlobalDomain._HIHideMenuBar = false;

  services.skhd.enable = true;
  services.skhd.package = pkgs.skhd;
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
      # This version of SKHD (0.3.0) doesn't support this yet
      # fn - n [
      #    "firefox": ${skhd} -k "ctrl - pagedown"
      #    "chrome" : ${skhd} -k "ctrl - pagedown"
      #    *        : ${skhd} -k "hyper - n"
      # ]
      fn - n:       ${skhd} -k "ctrl - pagedown"

      fn - o:       ${skhd} -k "hyper - o"
      # This version of SKHD (0.3.0) doesn't support this yet
      # fn - p [
      #    "firefox": ${skhd} -k "ctrl - pageup"
      #    "chrome" : ${skhd} -k "ctrl - pageup"
      #    *        : ${skhd} -k "hyper - p"
      # ]
      fn - p:       ${skhd} -k "ctrl - pageup"

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
  system.keyboard.mappings = [
    {
      productId = 273;
      vendorId = 2131;
      mappings = {
        # Bind Caps Lock to Left Function for Realforce 87u.
        "Keyboard Caps Lock" = "Keyboard Left Function (fn)";
      };
    }

    {
      productId = 638;
      vendorId = 1452;
      mappings = {
        # For the built-in MacBook keyboard, change the modifiers to match a
        # traditional keyboard layout.
        "Keyboard Caps Lock" = "Keyboard Left Function (fn)";
        "Keyboard Left Alt" = "Keyboard Left GUI";
        "Keyboard Left Function (fn)" = "Keyboard Left Control";
        "Keyboard Left GUI" = "Keyboard Left Alt";
        "Keyboard Right Alt" = "Keyboard Right Control";
        "Keyboard Right GUI" = "Keyboard Right Alt";
      };
    }
  ];

  programs.zsh.enable = true;

  environment = {
    systemPackages = with pkgs; [
      alacritty
      # local-packages.mac-apps.Anki
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
