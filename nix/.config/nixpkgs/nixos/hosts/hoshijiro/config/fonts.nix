{ pkgs, ... }:

{
  fonts = {
    fonts = [
      pkgs.dejavu_fonts
      pkgs.emojione
      pkgs.liberation_ttf
      pkgs.noto-fonts
      pkgs.noto-fonts-cjk
      pkgs.noto-fonts-emoji
      pkgs.opensans-ttf
    ];

    # Even though the default is false, there are several other modules that set
    # this to "mkDefault true".  What I'm trying to avoid is not having sensible
    # set of default fonts, but situations like this:
    #
    # ❯ fc-match "Noto Sans CJK"
    # FreeMono.ttf: "FreeMono" "Regular"
    enableDefaultFonts = false;
  };
}
