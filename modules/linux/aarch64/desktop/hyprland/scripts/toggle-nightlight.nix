{ pkgs, ... }:
pkgs.writeShellScriptBin "toggle-nightlight" ''
  if ${pkgs.procps}/bin/pgrep -x hyprsunset >/dev/null; then
    ${pkgs.procps}/bin/pkill -x hyprsunset
    ${pkgs.libnotify}/bin/notify-send -u low "Night Mode" "Disabled"
  else
    ${pkgs.hyprsunset}/bin/hyprsunset --temperature 4000 &
    ${pkgs.libnotify}/bin/notify-send -u low "Night Mode" "Enabled (4000K)"
  fi
''
