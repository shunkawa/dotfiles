{ config, lib, pkgs, ... }:

# This module does two things
# 1. Create a volume at /spotlight, which is owned by nix
# 2. Create macOS alias files in that directory which link to "apps"
#    that were found in the current system closure
#    (config.system.build.applications on nix-darwin)
#
# Motivation for creating a separate volume:
# 1. This solution works without creating a separate volume, but I also want to
#    disable Spotlight indexing for /Users.  Apps like Alfred don't work without
#    a Spotlight index.  Therefore, the link destination needs to be somewhere
#    indexed by Spotlight.  This can be a separate volume, like /Applications.
#    I chose "/spotlight".
# 2. I don't want to use "rm -rf" anywhere near "${HOME}".
#
# Motivation for using aliases:
# 1. Apps like Alfred don't follow symlinks.  Even if you configure it to
#   respect "public.symlink" in "User-defined file types to show in the default
#   results", it will not follow symlinks by design:
#   https://www.alfredforum.com/topic/4604-directory-symlinks-resolved-in-search-scope/
# 2. Alfred can be configured to use "com.apple.alias-file" ("alias") files in
#   "User-defined file types to show in the default results".
#
# Motivation for using Swift to create alias files:
# 1. The "supported" way to create these in scripts is to use "osascript" (like
#    `osascript -e 'tell application "Finder" to make new alias ...'`) but it
#    also forces the terminal to request permission (a popup prompting for
#    authentication by password) for each alias that is created.  If there are
#    may aliases to create, this obviously unacceptable.
# 2. It's possible to use the URL.bookmarkData to instance method to create
#    alias files instead:
#    https://developer.apple.com/documentation/foundation/nsurl/1417795-bookmarkdata
#
# This is basically the solution described here: https://github.com/NixOS/nix/issues/1278

with lib;
let
  cfg = attrByPath [ "services" "local-modules" "nix-darwin" "link-apps" ] { } config;

  createVolumeToLinkApps = (
    (builtins.toString (
      pkgs.callPackage
        ({ stdenv }:

          stdenv.mkDerivation rec {
            name = "create-apps-volume";
            unpackPhase = "true"; # nothing to unpack
            src = ./create-apps-volume.sh;
            dontConfigure = true;
            buildInputs = [ ];
            dontBuild = true;
            installPhase = ''
              install -D -m755 $src $out/bin/create-apps-volume
            '';
            meta = with stdenv.lib; {
              license = licenses.mit;
              platforms = platforms.darwin;
              maintainers = with maintainers; [ eqyiel ];
            };
          }
        ) { }
    )) + "/bin/create-apps-volume"
  );

  createMacOSAlias = (
    (builtins.toString (
      pkgs.callPackage
        ({ stdenv }:

          stdenv.mkDerivation rec {
            name = "create-macos-alias";

            unpackPhase = "true"; # nothing to unpack

            src = ./create-macos-alias.swift;

            dontConfigure = true;

            buildInputs = [ ];

            dontBuild = true;

            installPhase = ''
              install -D -m755 $src $out/bin/create-macos-alias
            '';

            meta = with stdenv.lib; {
              license = licenses.mit;
              platforms = platforms.darwin;
              maintainers = with maintainers; [ eqyiel ];
            };
          }
        ) { }
    )) + "/bin/create-macos-alias"
  );
in
{
  options = {
    services.local-modules.nix-darwin.link-apps = {
      enable = mkEnableOption "create aliases (not symlinks) for macOS Apps at activation time";
    };
  };

  config = mkIf cfg.enable {
    system.activationScripts.postActivation.text = ''
      ${createVolumeToLinkApps}

      if test -d "/spotlight"; then
        if test -d "/spotlight/Applications"; then
          rm -rf "/spotlight/Applications"
        fi

        mkdir -p "/spotlight/Applications"

        for app in $("${pkgs.findutils}/bin/find" "${config.system.build.applications}/Applications" -iname '*.app'); do
          src="''${app}"
          dest="/spotlight/Applications/$("${pkgs.coreutils}/bin/basename" "''${app}" .app).app"
          echo "creating alias for ''${src} at ''${dest}..."
          ${createMacOSAlias} "''${src}" "''${dest}"
        done
      else
        echo "no such directory /spotlight, does the volume exist?" >&2
      fi
    '';

  };
}
