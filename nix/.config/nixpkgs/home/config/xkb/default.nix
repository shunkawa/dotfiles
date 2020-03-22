{ pkgs, lib, ... }:

with lib;

mkIf pkgs.stdenv.isLinux {
  # I like to use the Hyper key in Emacs, but by default Gnome treats it the
  # same as Super so Hyper + L will lock the screen instead of navigating to the
  # pane to the right.
  #
  # This solution is from the answer here:
  #
  # https://askubuntu.com/questions/423627/how-to-make-hyper-and-super-keys-not-do-the-same-thing
  home.file.".config/xkb/symbols/local".source = pkgs.writeText "super-hyper" ''
    default  partial modifier_keys
    xkb_symbols "superhyper" {
      modifier_map Mod3 { Super_L, Super_R };

      key <SUPR> {    [ NoSymbol, Super_L ]   };
      modifier_map Mod3   { <SUPR> };

      key <HYPR> {    [ NoSymbol, Hyper_L ]   };
      modifier_map Mod4   { <HYPR> };
    };
  '';

  systemd.user.services.xkb-separate-super-and-hyper = {
    Unit = {
      Description = "Put super and hyper on different modifiers";
      After = [ "graphical-session-pre.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = builtins.toString (pkgs.writeScript "xkb-separate-super-and-hyper" ''
        #!${pkgs.stdenv.shell}
        ${pkgs.xorg.setxkbmap}/bin/setxkbmap -print \
          | ${pkgs.gnused}/bin/sed -e '/xkb_symbols/s/"[[:space:]]/+local&/' \
          | ${pkgs.xorg.xkbcomp}/bin/xkbcomp -I''${HOME}/.config/xkb - ''${DISPLAY}
      '');
      Type = "oneshot";
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  systemd.user.timers.xkb-separate-super-and-hyper = {
    Unit = {
      Description = "Put super and hyper on different modifiers";
    };

    Timer = {
      OnUnitActiveSec = "5min";
    };

    Install = {
      WantedBy = [ "timers.target" ];
    };
  };
}
