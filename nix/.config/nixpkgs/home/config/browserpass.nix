{ pkgs, lib, ... }:

with lib;

let
  target = if pkgs.stdenv.isLinux
    then ".mozilla/native-messaging-hosts/com.dannyvankooten.browserpass.json"
    else "/Library/Application Support/Mozilla/NativeMessagingHosts/com.dannyvankooten.browserpass.json";
in {
  home.file."${target}".source =
    (pkgs.runCommand "com.dannyvankooten.browserpass.json" {} ''
      cp "${pkgs.browserpass}/lib/mozilla/native-messaging-hosts/com.dannyvankooten.browserpass.json" $out
    '');
}
