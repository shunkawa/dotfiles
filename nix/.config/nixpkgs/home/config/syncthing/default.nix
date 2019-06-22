args@{ lib, pkgs, ... }:

with lib;

let
  mkVal = value:
    if (value == true) then "true"
    else if (value == false) then "false"
    else if (value == null) then ""
    else if (isInt value) then (toString value)
    else value;

  deviceNames = {
    cloud = "cloud.maher.fyi";
    ayanami = "ayanami.maher.fyi";
    pc2218 = "pc2218";
    pixel = "pixel";
  };

  # .stignore isn't synced, but necessary for ignoring files.
  #
  # A workaround is to have a file like this that does get synced, and
  # include it from .stignore.
  stignore = pkgs.writeText "stignore" ''
    // Place this file in the root of your synced folder include it like this:
    // $ cat <<<EOF > .stignore
    // #include .stignore_synced
    // EOF

    (?d)*nix/store/**
    (?d)*result/*
    (?d).DS_Store
    (?d)node_modules/**
    // A NixOS artifact that is owned by root
    (?d).version-suffix
    (?d)ios/build/**
    (?d)android/build/**
  '';

  devices = mapAttrs (name: value: recursiveUpdate {
    device = {
      compression = "metadata";
      introducer = false;
      skipIntroductionRemovals = false;
      introducedBy = null;
      inherit name;
    };
  } value) ({
    "${deviceNames.cloud}" = {
      device = {
        id = "HWRJGYH-3BZL4DZ-QDIPELO-AQAFUNR-6UPK5VM-5MK2NV6-R572BXS-KH6CHQG";
      };
    };

    "${deviceNames.ayanami}" = {
      device = {
        id = "64C2O5L-G37ML5Z-PNOJJZN-GBW5PVE-MKEWNHU-ACDDXUS-LENXMUM-5DYXHQM";
      };
    };

    "${deviceNames.pc2218}" = {
      device = {
        id = "C5GB32Q-RH52U3Y-5UXIRNQ-US7MOWA-5UB7FWJ-XFRXPTA-LWJSXII-E6T4WQF";
      };
    };

    "${deviceNames.pixel}" = {
      device = {
        id = "AMMXC5J-BLXQZ6K-JN7NP4I-6DDBEWP-YUZ77LS-FHMQCWN-Y7RL4VQ-MPAHHQ7";
      };
    };
  });

  folders = mapAttrs (name: value: recursiveUpdate {
    folder = {
      label = name;
      type = "readwrite";
      rescanIntervalS = 3600;
      ignorePerms = false;
      autoNormalize = true;
      fsWatcherEnabled = true;
      fsWatcherDelayS = 10;
    };

    sharedWith = [];

    minDiskFree = null;

    versioning = null;

    options = {
      minDiskFree = 0;
      copiers = 0;
      pullers = 0;
      hashers = 0;
      order = "random";
      ignoreDelete = false;
      scanProgressIntervalS = 0;
      pullerSleepS = 0;
      pullerPauseS = 0;
      maxConflicts = 10;
      disableSparseFiles = false;
      disableTempIndexes = false;
      fsync = false;
      paused = false;
      autoAcceptFolders = false;
      weakHashThresholdPct = 25;
      markerName = ".stfolder";
    };
  } value) {
    git = {
      folder = {
        id = "kutcp-g4uze";
        path = "~/sync/git";
      };

      participants = with deviceNames; [
        ayanami cloud pc2218
      ];
    };

    history = {
      folder = {
        id = "guqnn-a5dvt";
        path = "~/sync/history";
      };

      versioning = {
        type = "trashcan";
        params = {
          command = null;
          maxAge = 0;
          versionsPath = null;
          keep = 10;
          cleanoutDays = 0;
        };
      };

      participants = with deviceNames; [
        ayanami cloud
      ];
    };

    org = {
      folder = {
        id = "qedw7-nj3dn";
        path = "~/sync/org";
      };

      versioning = {
        type = "trashcan";
        params = {
          command = null;
          maxAge = 0;
          versionsPath = null;
          keep = 10;
          cleanoutDays = 0;
        };
      };

      participants = with deviceNames; [
        ayanami cloud
      ];
    };

    android = {
      folder = {
        id = "sj9zu-db4q4";
        path = "~/sync/android";
      };

      versioning = {
        type = "trashcan";
        params = {
          command = null;
          maxAge = 0;
          versionsPath = null;
          keep = 10;
          cleanoutDays = 0;
        };
      };

      participants = with deviceNames; [
        ayanami cloud pixel
      ];
    };

    memes = {
      folder = {
        id = "zdmxs-7yk3u";
        path = "~/sync/memes";
      };

      versioning = {
        type = "trashcan";
        params = {
          command = null;
          maxAge = 0;
          versionsPath = null;
          keep = 10;
          cleanoutDays = 0;
        };
      };

      participants = with deviceNames; [
        cloud ayanami
      ];
    };
  };

  mkConfig = (hostname: ''
    <configuration version="28">
      ${concatStringsSep "\n" (mapAttrsToList (_: value: ''
        <folder ${concatStringsSep " "
          (mapAttrsToList (name: value: ''${name}="${mkVal value}"'')
            value.folder)}>
        ${concatMapStringsSep "\n" (deviceName: ''
          <device
            id="${mkVal devices."${deviceName}".device.id}"
            introducedBy=""
          >
          </device>
        '') (builtins.filter
                (element: element != hostname)
                  value.participants)}
          ${if value.minDiskFree == null then ''
            <minDiskFree unit="">0</minDiskFree>
            '' else ''
            <minDiskFree unit="${mkVal (attrByPath ["minDiskFree" "unit"] {} value)}">
              ${mkVal (attrByPath ["minDiskFree" "value"] {} value)}
            </minDiskFree>
          ''}
          ${if value.versioning == null then ""
             else ''
             <versioning type="${value.versioning.type}">
               ${(concatStringsSep "\n" (mapAttrsToList
                 (name: value: ''
                   <param key="${name}" val="${mkVal value}"></param>
                 '')
                 (attrByPath ["versioning" "params"] {} value)))
               }
             </versioning>
          ''}
          ${concatStringsSep "\n"
            (mapAttrsToList (name: value: "<${name}>${mkVal value}</${name}>")
              value.options)}
        </folder>
      '') folders)}
      ${concatStringsSep "\n" (mapAttrsToList (_: value: ''
        <device
          id="${mkVal value.device.id}"
          name="${mkVal value.device.name}"
          compression="${mkVal value.device.compression}"
          introducer="${mkVal value.device.introducer}"
          skipIntroductionRemovals="${mkVal value.device.skipIntroductionRemovals}"
          introducedBy="${mkVal value.device.introducedBy}">
            <address>dynamic</address>
            <paused>false</paused>
        </device>
      '') devices)}
      <gui enabled="true" tls="false" debugging="false">
        <address>127.0.0.1:8384</address>
        <apikey>uQeheoGH62Fw9o6GZvVmvd2V3Twan3Ud</apikey>
        <theme>default</theme>
      </gui>
      <options>
        <listenAddress>default</listenAddress>
        <globalAnnounceServer>default</globalAnnounceServer>
        <globalAnnounceEnabled>true</globalAnnounceEnabled>
        <localAnnounceEnabled>true</localAnnounceEnabled>
        <localAnnouncePort>21027</localAnnouncePort>
        <localAnnounceMCAddr>[ff12::8384]:21027</localAnnounceMCAddr>
        <maxSendKbps>0</maxSendKbps>
        <maxRecvKbps>0</maxRecvKbps>
        <reconnectionIntervalS>60</reconnectionIntervalS>
        <relaysEnabled>true</relaysEnabled>
        <relayReconnectIntervalM>10</relayReconnectIntervalM>
        <startBrowser>true</startBrowser>
        <natEnabled>true</natEnabled>
        <natLeaseMinutes>60</natLeaseMinutes>
        <natRenewalMinutes>30</natRenewalMinutes>
        <natTimeoutSeconds>10</natTimeoutSeconds>
        <urAccepted>2</urAccepted>
        <urSeen>3</urSeen>
        <urUniqueID>rwCw5uQ5</urUniqueID>
        <urURL>https://data.syncthing.net/newdata</urURL>
        <urPostInsecurely>false</urPostInsecurely>
        <urInitialDelayS>1800</urInitialDelayS>
        <restartOnWakeup>true</restartOnWakeup>
        <autoUpgradeIntervalH>12</autoUpgradeIntervalH>
        <upgradeToPreReleases>true</upgradeToPreReleases>
        <keepTemporariesH>24</keepTemporariesH>
        <cacheIgnoredFiles>false</cacheIgnoredFiles>
        <progressUpdateIntervalS>5</progressUpdateIntervalS>
        <limitBandwidthInLan>false</limitBandwidthInLan>
        <minHomeDiskFree unit="%">1</minHomeDiskFree>
        <releasesURL>https://upgrades.syncthing.net/meta.json</releasesURL>
        <overwriteRemoteDeviceNamesOnConnect>false</overwriteRemoteDeviceNamesOnConnect>
        <tempIndexMinBlocks>10</tempIndexMinBlocks>
        <unackedNotificationID>fsWatcherNotification</unackedNotificationID>
        <trafficClass>0</trafficClass>
        <defaultFolderPath>~</defaultFolderPath>
        <setLowPriority>true</setLowPriority>
        <minHomeDiskFreePct>0</minHomeDiskFreePct>
      </options>
    </configuration>
  '');

in {
  services.syncthing = mkIf pkgs.stdenv.isLinux { enable = true; };

  home.file =
    let
      configPath = if pkgs.stdenv.isLinux then ".config/syncthing/config.xml"
        else "Library/Application\ Support/syncthing/config.xml";
    in {
      "${configPath}".source =
          pkgs.writeText "syncthing-config"
          (mkConfig (if (attrByPath ["actualHostname"] args) == null
            then (import pkgs.local-packages.get-hostname)
            else (attrByPath ["actualHostname"] args)));
    };

  # This is a hack to create .stignore files, which syncthing doesn't allow to
  # be symlinks to /nix/store.
  home.activation.createStIgnoreFiles =
    (import <home-manager/modules/lib/dag.nix> { inherit lib; }).dagEntryAfter
      ["writeBoundary"]
        (concatStringsSep "\n" (mapAttrsToList
          (_: value: ''
            install -Dm644 ${stignore} ${(removeSuffix "/" value.folder.path)}/.stignore
          '') folders));
}
