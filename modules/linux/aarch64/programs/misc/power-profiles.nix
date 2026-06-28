{ pkgs, ... }:
let
  cycle-power-profile = pkgs.writeShellScriptBin "cycle-power-profile" ''
    CURRENT=$(powerprofilesctl get 2>/dev/null) || {
      ${pkgs.libnotify}/bin/notify-send -u low "Power Profile" "power-profiles-daemon not running"
      exit 1
    }
    case "$CURRENT" in
      balanced)     NEXT=performance ;;
      performance)  NEXT=power-saver ;;
      power-saver)  NEXT=balanced ;;
      *)            NEXT=balanced ;;
    esac
    powerprofilesctl set "$NEXT"
    ${pkgs.libnotify}/bin/notify-send -u low "Power Profile" "$NEXT"
  '';
in
{
  services.power-profiles-daemon.enable = true;
  environment.systemPackages = [ cycle-power-profile ];
}
