{ config, lib, pkgs, ... }:

{
  hardware.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
    extraConfig = let
      # This should be the output of `pacmd list-sinks | grep -A1 "* index" | grep -oP "<\K[^ >]+"`
      slave = "alsa_output.pci-0000_00_1b.0.analog-stereo";
    in ''
      # https://askubuntu.com/questions/60837/record-a-programs-output-with-pulseaudio
      load-module module-combine-sink sink_name=record-and-play slaves=${slave} sink_properties=device.description="Record-and-Play"
      # set-default-sink record-and-play
    '';
  };
  environment.systemPackages = with pkgs; [
    pavucontrol
    (pkgs.stdenv.mkDerivation rec {
      name = "record-pulse-output";

      unpackPhase = "true";

      dontBuild = true;

      dontConfigure = true;

      installPhase = ''
        mkdir -p $out/bin

        cat > "$out/bin/record-pulse-output" <<EOF
        #!${pkgs.stdenv.shell}

        set -e

        usage() {
          echo "Usage:"
          echo "${name} output.wav"
          echo "${name} output.ogg"
          echo "${name} output.flac"
          echo "etc"

          exit 1
        }

        if [ ! "\$#" -eq 1 ]; then
          usage
        fi

        parec -d record-and-play.monitor |
          ${pkgs.sox}/bin/sox -t raw -b 16 -e signed -c 2 -r 44100 - "\$@"
        EOF

        chmod +x "$out/bin/record-pulse-output"
      '';
    })
  ];
}
