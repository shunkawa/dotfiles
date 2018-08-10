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
    tomoyo = "maher.fyi";
    hoshijiro = "hoshijiro.maher.fyi";
    ayanami = "ayanami.maher.fyi";
    hanekawa = "hanekawa.local";
    nexus = "nexus-5x";
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
    "${deviceNames.tomoyo}" = {
      device = {
        id = "THQKP7R-GSBJTZT-7MFM4SF-DYVA7FZ-IYODSZC-YVAPLVM-BU3FM25-6N4JLQB";
      };
    };

    "${deviceNames.hoshijiro}" = {
      device = {
        id = "IO2LARC-WUVNBXV-IMWNJX5-TIKFUDH-EUV3CZH-BI6VQT3-46VYPWD-XDOH7AO";
      };
    };

    "${deviceNames.ayanami}" = {
      device = {
        id = "64C2O5L-G37ML5Z-PNOJJZN-GBW5PVE-MKEWNHU-ACDDXUS-LENXMUM-5DYXHQM";
      };
    };

    "${deviceNames.hanekawa}" = {
      device = {
        id = "IY4ARVX-QWWGGMW-OSTY7B4-ODOXIQ2-6K7W2YJ-DROMFPW-XWKKNRY-4BLW6QD";
      };
    };

    "${deviceNames.nexus}" = {
      device = {
        id = "FTZEHHM-RPVSGSF-TRD63QZ-XULA74B-XTI5HY3-ZSES35Z-VFXX4RK-J43PSAZ";
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
        hoshijiro hanekawa ayanami tomoyo
      ];
    };

    history = {
      folder = {
        id = "guqnn-a5dvt";
        path = "~/sync/history";
      };

      versioning = {
        type = "trashcan";
          command = null;
          maxAge = 0;
          versionsPath = null;
          keep = 10;
          cleanoutDays = 0;
      };

      participants = with deviceNames; [
        hoshijiro hanekawa ayanami tomoyo
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
        nexus hoshijiro hanekawa ayanami tomoyo
      ];
    };

    android = {
      folder = {
        id = "sj9zu-db4q4";
        path = "~/sync/android";
      };

      versioning = null;

      participants = with deviceNames; [
        nexus hoshijiro tomoyo
      ];
    };

    memes = {
      folder = {
        id = "zdmxs-7yk3u";
        path = "~/sync/memes";
      };

      versioning = null;

      participants = with deviceNames; [
        hanekawa hoshijiro tomoyo
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
  services.syncthing = mkIf pkgs.stdenv.isLinux { enable = true; tray = true; };

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
