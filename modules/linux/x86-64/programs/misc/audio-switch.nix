{ pkgs, ... }:
let
  audio-switch = pkgs.writeShellScriptBin "audio-switch" ''
    SINKS=$(${pkgs.pulseaudio}/bin/pactl -f json list sinks | \
      ${pkgs.jq}/bin/jq '[.[] | select((.ports | length == 0) or ([.ports[]? | .availability != "not available"] | any))]')

    COUNT=$(printf '%s' "$SINKS" | ${pkgs.jq}/bin/jq 'length')
    (( COUNT == 0 )) && { ${pkgs.libnotify}/bin/notify-send "Audio" "No audio devices found"; exit 1; }

    CURRENT=$(${pkgs.pulseaudio}/bin/pactl get-default-sink)
    CURRENT_IDX=$(printf '%s' "$SINKS" | ${pkgs.jq}/bin/jq -r --arg n "$CURRENT" 'map(.name) | index($n)')

    if [[ $CURRENT_IDX == "null" ]]; then
      NEXT_IDX=0
    else
      NEXT_IDX=$(( (CURRENT_IDX + 1) % COUNT ))
    fi

    NEXT_NAME=$(printf '%s' "$SINKS" | ${pkgs.jq}/bin/jq -r ".[$NEXT_IDX].name")
    NEXT_DESC=$(printf '%s' "$SINKS" | ${pkgs.jq}/bin/jq -r ".[$NEXT_IDX].description")

    ${pkgs.pulseaudio}/bin/pactl set-default-sink "$NEXT_NAME"
    ${pkgs.libnotify}/bin/notify-send -u low "Audio Output" "$NEXT_DESC"
  '';
in
{
  environment.systemPackages = [ audio-switch ];
}
