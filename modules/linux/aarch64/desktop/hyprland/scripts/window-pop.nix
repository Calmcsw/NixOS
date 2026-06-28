{ pkgs, ... }:
pkgs.writeShellScriptBin "window-pop" ''
  width=''${1:-1300}
  height=''${2:-900}

  active=$(hyprctl activewindow -j)
  pinned=$(printf '%s' "$active" | ${pkgs.jq}/bin/jq -r '.pinned')
  addr=$(printf '%s' "$active" | ${pkgs.jq}/bin/jq -r '.address')

  [[ -z $addr || $addr == "null" ]] && exit 0

  if [[ $pinned == "true" ]]; then
    hyprctl dispatch pin >/dev/null
    hyprctl dispatch togglefloating >/dev/null
  else
    hyprctl dispatch togglefloating >/dev/null
    hyprctl dispatch resizewindowpixel "exact $width $height" >/dev/null
    hyprctl dispatch centerwindow >/dev/null
    hyprctl dispatch pin >/dev/null
    hyprctl dispatch alterzorder top >/dev/null
  fi
''
