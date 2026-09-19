{ pkgs }:
pkgs.writeShellApplication {
  name = "toggle-monitor";
  runtimeInputs = with pkgs; [ jq libnotify nix ];
  text = ''
    NIXOS_DIR="''${NIXOS_DIR:-$HOME/NixOS}"
    HOST="$(hostname)"
    MONITORS_FILE="$NIXOS_DIR/hosts/linux/x86-64/$HOST/monitors.nix"

    hl_monitor_disable() {
      hyprctl eval "return hl.monitor({ output = '$1', disabled = true })" -q
    }

    hl_monitor_enable() {
      local output="$1" mode="$2" position="$3" scale="$4" transform="$5"
      hyprctl eval "return hl.monitor({ output = '$output', disabled = false, mode = '$mode', position = '$position', scale = $scale, transform = $transform })" -q
    }

    restore_from_state() {
      local f="$1"
      local name w h r x y s t
      name=$(jq -r '.name'        "$f")
      w=$(jq -r '.width'          "$f")
      h=$(jq -r '.height'         "$f")
      r=$(jq -r '.refreshRate'    "$f")
      x=$(jq -r '.x'             "$f")
      y=$(jq -r '.y'             "$f")
      s=$(jq -r '.scale'          "$f")
      t=$(jq -r '.transform'      "$f")
      hl_monitor_enable "$name" "''${w}x''${h}@''${r}" "''${x}x''${y}" "$s" "$t"
    }

    restore_from_nix() {
      local target="$1"
      local entry mode pos scale transform x y
      entry=$(nix eval --impure --json --expr "
        let ms = (import $MONITORS_FILE).monitors;
        in builtins.head (builtins.filter (e: e.output == \"$target\") ms)
      " 2>/dev/null)
      [ -z "$entry" ] && return 1
      mode=$(echo      "$entry" | jq -r '.mode')
      pos=$(echo       "$entry" | jq -r '.position')
      scale=$(echo     "$entry" | jq -r '.scale')
      transform=$(echo "$entry" | jq -r '.transform // 0')
      hl_monitor_enable "$target" "$mode" "$pos" "$scale" "$transform"
    }

    # If a saved state exists, re-enable that monitor
    existing=$(find /tmp -maxdepth 1 -name 'toggle-monitor-*.json' 2>/dev/null | head -1)
    if [ -n "$existing" ]; then
      name=$(basename "$existing" .json | sed 's/toggle-monitor-//')
      target=$(jq -r '.description | gsub(" \\((?<x>[^)]+)\\)$"; "")' "$existing" | sed 's/^/desc:/')
      restore_from_state "$existing" || restore_from_nix "$target" || {
        notify-send -u critical "Monitor" "Failed to restore $name"
        exit 1
      }
      rm "$existing"
      notify-send -u low "Monitor" "Enabled $name"
      exit 0
    fi

    # No saved state — disable the monitor under cursor
    cursor=$(hyprctl cursorpos -j)
    cx=$(echo "$cursor" | jq '.x')
    cy=$(echo "$cursor" | jq '.y')

    monitor=$(hyprctl monitors -j | jq --argjson cx "$cx" --argjson cy "$cy" '
      .[] | select(
        . as $m |
        ((($m.transform // 0) % 2) == 1) as $rotated |
        (if $rotated then $m.height else $m.width  end) as $lw |
        (if $rotated then $m.width  else $m.height end) as $lh |
        $m.x <= $cx and $cx < ($m.x + $lw) and
        $m.y <= $cy and $cy < ($m.y + $lh)
      )
    ')

    if [ -z "$monitor" ]; then
      notify-send -u critical "Monitor" "Could not detect monitor under cursor"
      exit 1
    fi

    name=$(echo "$monitor" | jq -r '.name')
    state_file="/tmp/toggle-monitor-''${name}.json"

    echo "$monitor" > "$state_file"
    hl_monitor_disable "$name"
    notify-send -u low "Monitor" "Disabled $name"
  '';
}
