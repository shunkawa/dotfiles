{ stdenv
, fetchFromGitHub
, alsaLib
, file
, fluidsynth
, ffmpeg
, jack2
, liblo
, libpulseaudio
, libsndfile
, pkgconfig
, python3Packages
, which
, withFrontend ? true
, withQt ? true
, qtbase ? null
, wrapQtAppsHook ? null
, withGtk2 ? true
, gtk2 ? null
, withGtk3 ? true
, gtk3 ? null
  # macos stuff
, CoreAudioKit
, WebKit
}:

with stdenv.lib;

assert withFrontend -> python3Packages ? pyqt5;
assert withQt -> qtbase != null;
assert withQt -> wrapQtAppsHook != null;
assert withGtk2 -> gtk2 != null;
assert withGtk3 -> gtk3 != null;

stdenv.mkDerivation rec {
  pname = "carla";
  version = "2.1";

  src = fetchFromGitHub {
    owner = "falkTX";
    repo = pname;
    rev = "v${version}";
    sha256 = "074y40yrgl3qrdr3a5vn0scsw0qv77r5p5m6gc89zhf20ic8ajzc";
  };

  nativeBuildInputs = [
    python3Packages.wrapPython
    pkgconfig
    which
    wrapQtAppsHook
  ];

  pythonPath = with python3Packages; [
    rdflib
    pyliblo
  ] ++ optional withFrontend pyqt5;

  buildInputs = [
    file
    liblo
    fluidsynth
    ffmpeg
    libsndfile
  ] ++ optionals stdenv.isLinux [
    alsaLib
    jack2
    libpulseaudio
  ] ++ optionals stdenv.isDarwin [
    CoreAudioKit
    WebKit
  ]
  ++ pythonPath
  ++ optional withQt qtbase
  ++ optional withGtk2 gtk2
  ++ optional withGtk3 gtk3;

  enableParallelBuilding = true;

  installFlags = [ "PREFIX=$(out)" ];

  dontWrapQtApps = true;

  postPatch = stdenv.lib.optionalString stdenv.isDarwin ''
    sed -i 's%include <fp.h>%include <math.h>%' source/modules/juce_graphics/image_formats/pnglib/pngpriv.h
  '';

  postFixup = ''
    # Also sets program_PYTHONPATH and program_PATH variables
    wrapPythonPrograms
    wrapPythonProgramsIn "$out/share/carla/resources" "$out $pythonPath"

    find "$out/share/carla" -maxdepth 1 -type f -not -name "*.py" -print0 | while read -d "" f; do
      patchPythonScript "$f"
    done
    patchPythonScript "$out/share/carla/carla_settings.py"

    for program in $out/bin/*; do
      wrapQtApp "$program" \
        --prefix PATH : "$program_PATH:${which}/bin" \
        --set PYTHONNOUSERSITE true
    done

    find "$out/share/carla/resources" -maxdepth 1 -type f -not -name "*.py" -print0 | while read -d "" f; do
      wrapQtApp "$f" \
        --prefix PATH : "$program_PATH:${which}/bin" \
        --set PYTHONNOUSERSITE true
    done
  '';

  meta = with stdenv.lib; {
    homepage = "http://kxstudio.sf.net/carla";
    description = "An audio plugin host";
    longDescription = ''
      It currently supports LADSPA (including LRDF), DSSI, LV2, VST2/3
      and AU plugin formats, plus GIG, SF2 and SFZ file support.
      It uses JACK as the default and preferred audio driver but also
      supports native drivers like ALSA, DirectSound or CoreAudio.
    '';
    license = licenses.gpl2Plus;
    maintainers = [ maintainers.minijackson ];
    platforms = platforms.unix;
  };
}
