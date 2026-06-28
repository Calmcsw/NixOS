{ pkgs, ... }:
pkgs.writeShellScriptBin "webcam-overlay" ''
  if ${pkgs.procps}/bin/pgrep -f "WebcamOverlay" >/dev/null; then
    ${pkgs.procps}/bin/pkill -f "WebcamOverlay"
    exit 0
  fi

  DEVICE=$(${pkgs.v4l-utils}/bin/v4l2-ctl --list-devices 2>/dev/null | grep -m1 "^[[:space:]]*/dev/video" | tr -d '[:space:]')
  if [[ -z $DEVICE ]]; then
    ${pkgs.libnotify}/bin/notify-send -u low "Webcam" "No webcam device found"
    exit 1
  fi

  SCALE=$(hyprctl monitors -j | ${pkgs.jq}/bin/jq -r '.[] | select(.focused) | .scale')
  TARGET_W=$(${pkgs.gawk}/bin/awk "BEGIN {printf \"%.0f\", 360 * $SCALE}")

  ${pkgs.ffmpeg}/bin/ffplay -f v4l2 -framerate 30 "$DEVICE" \
    -vf "scale=''${TARGET_W}:-1" \
    -window_title "WebcamOverlay" \
    -noborder \
    -fflags nobuffer -flags low_delay \
    -probesize 32 -analyzeduration 0 \
    -loglevel quiet &

  ${pkgs.libnotify}/bin/notify-send -u low "Webcam" "Overlay started — SUPER+CTRL+SHIFT+P to stop"
''
