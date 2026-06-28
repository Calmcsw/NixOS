{ pkgs, ... }:
let
  reminder = pkgs.writeShellScriptBin "reminder" ''
    format_remaining() {
      local seconds=$1 minutes remainder
      minutes=$((seconds / 60))
      remainder=$((seconds % 60))
      if (( minutes > 0 && remainder > 0 )); then
        echo "''${minutes}m ''${remainder}s"
      elif (( minutes > 0 )); then
        echo "''${minutes}m"
      else
        echo "''${remainder}s"
      fi
    }

    show_reminders() {
      local body="" now timer next remaining mins
      now=$(date +%s)
      while IFS=$'\t' read -r timer next; do
        [[ -z $timer || -z $next ]] && continue
        next=$(( next / 1000000 ))
        (( next <= now )) && continue
        remaining=$(( next - now ))
        mins=''${timer#reminder-}
        mins=''${mins%%m-*}
        body+="''${mins}-min reminder in $(format_remaining $remaining)"$'\n'
      done < <(systemctl --user list-timers --all --output=json "reminder-*.timer" 2>/dev/null | \
        ${pkgs.jq}/bin/jq -r '.[] | [.unit, .next] | @tsv')
      if [[ -z $body ]]; then
        ${pkgs.libnotify}/bin/notify-send "Reminders" "No outstanding reminders"
      else
        ${pkgs.libnotify}/bin/notify-send "Upcoming Reminders" "''${body%$'\n'}"
      fi
    }

    case ''${1:-} in
      show)
        show_reminders
        exit 0
        ;;
      clear)
        systemctl --user stop "reminder-*.timer" 2>/dev/null || true
        ${pkgs.libnotify}/bin/notify-send -u low "Reminders" "All reminders cleared"
        exit 0
        ;;
    esac

    MINUTES=$(${pkgs.yad}/bin/yad --entry --center \
      --title="Set Reminder" --text="Remind me in how many minutes?" \
      --button="Cancel:1" --button="Set:0" 2>/dev/null) || exit 0

    [[ -z $MINUTES || ! $MINUTES =~ ^[0-9]+$ ]] || (( MINUTES == 0 )) && exit 1

    set_at=$(date +%s)
    remind_at=$(date -d "+''${MINUTES} minutes" +%H:%M)
    unit="reminder-''${MINUTES}m-''${set_at}"

    systemd-run --user --quiet --collect \
      --on-active="''${MINUTES}m" --unit="$unit" \
      --setenv="DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS" \
      ${pkgs.libnotify}/bin/notify-send -u critical "Reminder" "Your ''${MINUTES}-minute reminder is up"

    ${pkgs.libnotify}/bin/notify-send -u low "Reminder set" "You'll be reminded at $remind_at"
  '';
in
{
  environment.systemPackages = [ reminder ];
}
