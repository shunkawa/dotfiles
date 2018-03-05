{ stdenv
, at_spi2_core
, cmake
, dbus
, epoxy
, fetchFromGitHub
, gettext
, gobjectIntrospection
, kdeconnect
, libXdmcp
, libappindicator-gtk3
, libpthreadstubs
, libxkbcommon
, nautilus-python
, pcre
, pkgconfig
, pythonPackages
, vala
, wrapGAppsHook
}:

stdenv.mkDerivation rec {
  name = "indicator-kdeconnect-" + version;
  version = "0.9.3";

  src = fetchFromGitHub {
    owner = "Bajoja";
    repo = "indicator-kdeconnect";
    rev = "416e9ed72f4db35c088d79e37d97fc0f26328e03";
    sha256 = "13jvmbspwl6svgnbarkr7wwm28463pbmb2qmscn9nalyfgggj4n3";
  };

  buildInputs = [
    at_spi2_core
    cmake
    dbus
    epoxy
    gettext
    gobjectIntrospection
    kdeconnect
    libXdmcp
    libappindicator-gtk3
    libpthreadstubs
    libxkbcommon
    nautilus-python
    pcre
    pkgconfig
    pythonPackages.pygobject3
    pythonPackages.requests_oauthlib
    vala
    wrapGAppsHook
  ];

}
