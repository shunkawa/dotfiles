{ config, lib, pkgs, ... }:

with lib;
let
  cfg = attrByPath [ "services" "local-modules" "nix-darwin" "spotlight" ] { } config;

  onOff = b: if b then "on" else "off";
in
{
  options = {
    services.local-modules.nix-darwin.spotlight = {
      enable = mkEnableOption "enable or disable Spotlight indexing for volumes at activation time";
      indexing = mkOption {
        type = types.submodule {
          options = {
            volumes = mkOption {
              type = types.attrsOf (types.submodule {
                options = {
                  enable = mkEnableOption "enable or disable Spotlight indexing this volume";
                  rebuild = mkEnableOption "whether to rebuild the index for this volume at activation time";
                  delete = mkEnableOption "whether to delete the index for this volume at activation time";
                };
              });
              default = { };
            };
          };
        };
        default = { };
      };
    };
  };

  config = mkIf cfg.enable {
    assertions =
      [
        {
          assertion = !(
            builtins.any
              (value: value == false)
              (
                mapAttrsToList
                  (name: value: true)
                  (
                    filterAttrs
                      (name: value: (attrByPath [ "rebuild" ] false value)
                        && (attrByPath [ "delete" ] false value))
                      cfg.indexing.volumes
                  )
              )
          );
          message = ''
            Options "rebuild" and "delete" for are mutually exclusive, please set one or the other.
          '';
        }
        {
          assertion =
            builtins.all
              (value: value == true)
              (
                mapAttrsToList
                  (name: value: true)
                  (
                    filterAttrs
                      (name: value: (attrByPath [ "enable" ] false value)
                        && (attrByPath [ "rebuild" ] false value))
                      cfg.indexing.volumes
                  )
              );
          message = ''
            Option "rebuild" should not be set if "enable" is not set.
          '';
        }
      ];

    system.activationScripts.postActivation.text =
      let
        indexingCommands = (
          mapAttrsToList
            (name: value:
              let onOrOff = "${onOff value.enable}"; in
              ''
                echo "Turning indexing ${onOrOff} for \"${name}\""

                if test -d "${name}"; then
                  sudo mdutil -i "${onOrOff}" "${name}"
                else
                  echo "warning: no such directory: \"${name}\""
                fi
              '')
            (filterAttrs (name: value: attrByPath [ "enable" ] false value) cfg.indexing.volumes)
        ) ++ (
          mapAttrsToList
            (name: _: ''
              echo "Erasing and rebuilding the Spotlight index for \"${name}\""

              if test -d "${name}"; then
                sudo mdutil -E "${name}"
              else
                echo "warning: no such directory: \"${name}\""
              fi
            '')
            (filterAttrs (name: value: attrByPath [ "rebuild" ] false value) cfg.indexing.volumes)
        ) ++ (
          mapAttrsToList
            (name: _: ''
              echo "Removing the Spotlight index directory for \"${name}\""

              if test -d "${name}"; then
                sudo mdutil -X "${name}"
              else
                echo "warning: no such directory: \"${name}\""
              fi

            '')
            (filterAttrs (name: value: attrByPath [ "delete" ] false value) cfg.indexing.volumes)
        ); in
      if ((builtins.length indexingCommands) > 0) then ''
        echo "configuring Spotlight indexing"
      '' + concatStringsSep "\n" indexingCommands + "\n"
      else "";
  };
}
