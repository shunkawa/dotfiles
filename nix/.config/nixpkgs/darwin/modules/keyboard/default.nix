{ config, lib, pkgs, ... }:

with lib;
let
  cfg = attrByPath [ "services" "local-modules" "nix-darwin" "keyboard" ] { } config;

  keyMappingTable = (
    mapAttrs
      (name: value:
        # hidutil accepts values that consists of 0x700000000 binary ORed with the
        # desired keyboard usage value.
        #
        # The actual number can be base-10 or hexadecimal.
        # 0x700000000
        #
        # 30064771072 == 0x700000000
        #
        # https://developer.apple.com/library/archive/technotes/tn2450/_index.html
        builtins.bitOr 30064771072 value)
      (import ./hid-usage-table.nix)
  ) // {
    # These are not documented.
    #
    # https://apple.stackexchange.com/a/396863/383501
    # http://www.neko.ne.jp/~freewing/software/macos_keyboard_setting_terminal_commandline/
    "Keyboard Left Function (fn)" = 1095216660483;
    "Keyboard Right Function (fn)" = 280379760050179;
  };
in
{
  options = {
    services.local-modules.nix-darwin.keyboard = {
      enable = mkEnableOption "enable or disable custom keyboards mappings";
      devices = mkOption {
        type = types.attrs;
        default = { };
        apply =
          let
            isTrue = element: element == true;
            isString = s: builtins.isString s;
          in
          element: assert (builtins.isAttrs element
            && builtins.all isTrue (
            mapAttrsToList
              (key: value: builtins.isAttrs value && builtins.all isString (builtins.attrValues value))
              element
          ) || abort "invalid value in keyboard mapping: ${builtins.toJSON element}"); element;
        example = literalExample ''
          services.local-modules.nix-darwin.keyboard = {
            enable = true;
            devices = {
              # Device ID of the internal keyboard only (check the output of
              # `system_profiler SPUSBDataType` or find it in Apple menu →
              # System Report → Hardware → USB)
              "0x027e" = {
                # Map left function key to left control
                "Keyboard Left Function (fn)" = "Keyboard Left Control";
              };
            };
          };
        '';
      };
    };
  };

  config =
    mkIf cfg.enable {
      assertions = (
        mapAttrsToList
          (key: value: {
            assertion = builtins.isAttrs value;
            message = "The value of ${key} must be of type attrs";
          })
          cfg.devices
      ) ++ (
        let validAttrs = builtins.attrNames keyMappingTable;
        in
        flatten (
          map
            (value: (
              mapAttrsToList
                (key: value:
                  let mkAssertion = element: {
                    assertion = builtins.elem element validAttrs;
                    message = "${element} must be in ${builtins.toJSON validAttrs}";
                  };
                  in [ (mkAssertion key) (mkAssertion value) ])
                value
            ))
            (builtins.attrValues cfg.devices)
        )
      );
      system.activationScripts.postActivation.text =
        let
          commands =
            mapAttrsToList
              (productId: value:
                let
                  userKeyMapping = builtins.toJSON ({
                    UserKeyMapping = (mapAttrsToList
                      (key: value: {
                        HIDKeyboardModifierMappingSrc = keyMappingTable."${key}";
                        HIDKeyboardModifierMappingDst = keyMappingTable."${value}";
                      })
                      value
                    );
                  }); in
                ''
                  system_profiler -json SPUSBDataType 2>/dev/null |
                    ${pkgs.jq}/bin/jq --raw-output '..|._items? | select (. != null) | ..|.product_id?' |
                     grep ${productId} 2>&1 >/dev/null ||
                       echo >&2 "[1;31mwarning: USB Keyboard with Product ID ${productId} does not exist, attempting to configure anyway (check the output of system_profiler SPUSBDataType)[0m"

                  # Erase existing key mapping
                  hidutil property --matching '{ "ProductID": ${productId} }' --set '${builtins.toJSON { UserKeyMapping = {}; }}' > /dev/null
                  hidutil property --matching '{ "ProductID": ${productId} }' --set '${userKeyMapping}' > /dev/null
                '')
              cfg.devices;
        in
        if ((builtins.length commands) > 0) then ''
          echo "configuring keyboard mapping..."
        '' + concatStringsSep "\n" commands + "\n"
        else "";
    };

}
