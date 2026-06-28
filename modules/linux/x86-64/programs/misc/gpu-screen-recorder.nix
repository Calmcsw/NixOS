{ pkgs, ... }:
let
  gsr-record = pkgs.writeShellScriptBin "gsr-record" ''
    XDG_VIDEOS_DIR="''${XDG_VIDEOS_DIR:-$HOME/Videos}"
    DIR="''${XDG_VIDEOS_DIR}/screen-record"
    mkdir -p "$DIR"

    if PID=$(${pkgs.procps}/bin/pgrep -x gpu-screen-recorder 2>/dev/null); then
      kill -INT "$PID"
      ${pkgs.libnotify}/bin/notify-send -u low "Recording" "Stopped — saved to $DIR"
      exit 0
    fi

    MONITOR=$(hyprctl monitors -j | ${pkgs.jq}/bin/jq -r '.[] | select(.focused) | .name')
    FILE="$DIR/recording_$(date +%Y%m%d_%Hh%Mm%Ss).mp4"

    ${pkgs.gpu-screen-recorder}/bin/gpu-screen-recorder \
      -w "$MONITOR" -f 60 -c mp4 -o "$FILE" &

    ${pkgs.libnotify}/bin/notify-send -u low "Recording" "Started on $MONITOR — SUPER+SHIFT+ALT+Print to stop"
  '';
in
{
  environment.systemPackages = with pkgs; [ gpu-screen-recorder gsr-record ];
}
