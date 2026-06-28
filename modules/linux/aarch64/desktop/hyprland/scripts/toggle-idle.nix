{ pkgs, ... }:
pkgs.writeShellScriptBin "toggle-idle" ''
  if ${pkgs.procps}/bin/pgrep -x hypridle >/dev/null; then
    systemctl --user stop hypridle
    ${pkgs.libnotify}/bin/notify-send -u low "Idle Lock" "Disabled — screen will not lock"
  else
    systemctl --user start hypridle
    ${pkgs.libnotify}/bin/notify-send -u low "Idle Lock" "Enabled — screen locks after inactivity"
  fi
''
