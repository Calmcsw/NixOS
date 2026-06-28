{ pkgs, ... }:
pkgs.writeShellScriptBin "cycle-monitor-scale" ''
  MONITOR_INFO=$(hyprctl monitors -j | ${pkgs.jq}/bin/jq -r '.[] | select(.focused == true)')
  ACTIVE=$(printf '%s' "$MONITOR_INFO" | ${pkgs.jq}/bin/jq -r '.name')
  CURRENT_SCALE=$(printf '%s' "$MONITOR_INFO" | ${pkgs.jq}/bin/jq -r '.scale')
  WIDTH=$(printf '%s' "$MONITOR_INFO" | ${pkgs.jq}/bin/jq -r '.width')
  HEIGHT=$(printf '%s' "$MONITOR_INFO" | ${pkgs.jq}/bin/jq -r '.height')
  REFRESH=$(printf '%s' "$MONITOR_INFO" | ${pkgs.jq}/bin/jq -r '.refreshRate')
  POS_X=$(printf '%s' "$MONITOR_INFO" | ${pkgs.jq}/bin/jq -r '.x')
  POS_Y=$(printf '%s' "$MONITOR_INFO" | ${pkgs.jq}/bin/jq -r '.y')

  SCALES=(1 1.25 1.6 2 3 4)

  CURRENT_IDX=$(${pkgs.gawk}/bin/awk -v s="$CURRENT_SCALE" -v list="''${SCALES[*]}" 'BEGIN {
    n = split(list, arr, " ")
    best = 0; best_diff = 1e9
    for (i = 1; i <= n; i++) {
      d = s - arr[i]; if (d < 0) d = -d
      if (d < best_diff) { best_diff = d; best = i - 1 }
    }
    print best
  }')

  if [[ ''${1:-} == "--reverse" ]]; then
    NEW_IDX=$(( (CURRENT_IDX - 1 + ''${#SCALES[@]}) % ''${#SCALES[@]} ))
  else
    NEW_IDX=$(( (CURRENT_IDX + 1) % ''${#SCALES[@]} ))
  fi

  NEW_SCALE=''${SCALES[$NEW_IDX]}

  hyprctl keyword monitor "$ACTIVE,''${WIDTH}x''${HEIGHT}@''${REFRESH},''${POS_X}x''${POS_Y},$NEW_SCALE" >/dev/null
  ${pkgs.libnotify}/bin/notify-send -u low "Monitor Scaling" "''${ACTIVE}: ''${NEW_SCALE}x"
''
