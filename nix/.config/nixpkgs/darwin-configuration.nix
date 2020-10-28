args@{ config, lib, pkgs, ... }:

{
  imports = [
    <home-manager/nix-darwin>
  ] ++ (import ./nix-darwin/modules/module-list.nix);

  home-manager.users."${builtins.getEnv "USER"}" = import ./home.nix;
  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;

  services.nix-daemon.enable = true;

  nix.nixPath = [
    "darwin-config=/Users/${(builtins.getEnv "USER")}/.config/nixpkgs/darwin-configuration.nix"
    "darwin=/Users/${(builtins.getEnv "USER")}/.nix-defexpr/darwin"
    "home-manager=${import ./nix-darwin/lib/home-manager.nix}"
    "nixpkgs=${import ./nix-darwin/lib/nixpkgs.nix}"
  ];

  # Note that this must not contain a trailing forward slash, or you'll get
  # errors like
  # > warning: substituter 'https://eqyiel.cachix.org' does not have a valid signature for path '/nix/store/kpmzy88syzcqrsy527zw5200mzx00v30-emacs-yasnippet-20200604.246'
  nix.binaryCaches = [ "https://eqyiel.cachix.org" ];
  nix.binaryCachePublicKeys = [ "eqyiel.cachix.org-1:hfFW3UakMJ2ad2vpZw8gvMrM06drgMGPAQuSI+xT8YQ=" ];

  nix.package = pkgs.nixUnstable;

  nixpkgs = {
    overlays = [
      (import ./overlays/emacs-overlay.nix)
      (import ./overlays/local-packages.nix)
    ];
    config = {
      allowUnfree = true;
    };
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

  fonts = {
    enableFontDir = true;
    fonts = [
      pkgs.dejavu_fonts
      pkgs.noto-fonts
      pkgs.noto-fonts-cjk
      pkgs.local-packages.nixpkgs."nixpkgs-unstable-2020-08-23".pkgs.noto-fonts-emoji # broken in 2020-10-10
      pkgs.noto-fonts-extra
    ];
  };

  system.activationScripts.postActivation.text = ''
    # Disable the sound effects on boot
    sudo nvram SystemAudioVolume=" "
  '';

  # TODO: figure out how to do this
  # defaults write com.apple.systemsound "com.apple.sound.uiaudio.enabled" -int 0
  #
  # TODO: even solid colors is a meme,
  # open /System/Library/Desktop\ Pictures/Solid\ Colors/Turquoise\ Green.png

  # Check `defaults read` for available keys.

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
  system.keyboard.mappings =
    let
      macbookKeyMappings = {
        "Keyboard Caps Lock" = "Keyboard Left Function (fn)";
        "Keyboard Left Alt" = "Keyboard Left GUI";
        "Keyboard Left Function (fn)" = "Keyboard Left Control";
        "Keyboard Left GUI" = "Keyboard Left Alt";
        "Keyboard Right Alt" = "Keyboard Right Control";
        "Keyboard Right GUI" = "Keyboard Right Alt";
      };
    in
    [
      {
        productId = 273;
        vendorId = 2131;
        mappings = {
          # Bind Caps Lock to Left Function for Realforce 87u.
          "Keyboard Caps Lock" = "Keyboard Left Function (fn)";
        };
      }

      {
        # 0x27e = 638
        # MacBook Pro (13-inch, 2020, Four Thunderbolt 3 ports)
        productId = 638;
        vendorId = 1452;
        mappings = macbookKeyMappings;
      }

      {
        # Different MacBook, with a different internal keyboard ID: 0x27b = 635
        # MacBook Pro (13-inch, 2018, Four Thunderbolt 3 Ports)
        productId = 635;
        vendorId = 1452;
        mappings = macbookKeyMappings;
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
      local-packages.qolibri
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

    pathsToLink = [
      # Almost everything is installed in the user profile, but this is required
      # so that home manager can link everything under /etc/profiles/per-user/$USER.
      "/"
    ];
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
