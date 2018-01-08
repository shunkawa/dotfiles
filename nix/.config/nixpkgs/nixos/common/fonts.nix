{ config, lib, pkgs, ... }:

{
  fonts = {
    fonts = (import ../../common/package-lists/fonts.nix) {
      inherit pkgs;
    };

    # Even though the default is false, there are several other modules that set
    # this to "mkDefault true".  What I'm trying to avoid is not having sensible
    # set of default fonts, but situations like this:
    #
    # ❯ fc-match "Noto Sans CJK"
    # FreeMono.ttf: "FreeMono" "Regular"
    enableDefaultFonts = false;
  };
}
