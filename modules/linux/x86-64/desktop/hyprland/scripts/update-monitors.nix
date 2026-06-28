{ pkgs }:
pkgs.writeShellApplication {
  name = "update-monitors";
  runtimeInputs = with pkgs; [ jq ];
  text = ''
    NIXOS_DIR="''${NIXOS_DIR:-$HOME/NixOS}"
    HOST="$(hostname)"
    MONITORS_FILE="$NIXOS_DIR/hosts/linux/x86-64/$HOST/monitors.nix"

    if ! command -v hyprctl &>/dev/null; then
      echo "error: hyprctl not found — is Hyprland running?"
      exit 1
    fi

    if [ ! -f "$MONITORS_FILE" ]; then
      echo "error: $MONITORS_FILE does not exist"
      exit 1
    fi

    json=$(hyprctl monitors -j)
    count=$(echo "$json" | jq 'length')

    echo "Detected $count monitor(s):"
    echo "$json" | jq -r '.[].description'
    echo ""

    primary_desc=$(echo "$json" | jq -r '.[0].description | gsub(" \\([^)]+\\)$"; "")')

    # Write monitors.nix
    {
      echo "{"
      echo "  monitors = ["
      echo "    { output = \"\"; mode = \"preferred\"; position = \"auto\"; scale = 1; }"
      echo "$json" | jq -r '.[] |
        (.description | gsub(" \\([^)]+\\)$"; "")) as $desc |
        "    { output = \"desc:\($desc)\"; mode = \"preferred\"; position = \"\(.x)x\(.y)\"; scale = \(.scale);\(if .transform != 0 then " transform = \(.transform);" else "" end) }"
      '
      echo "  ];"
      echo ""
      echo "  workspaces = ["
      echo "    { workspace = \"1\"; monitor = \"desc:$primary_desc\"; default = true; }"
      for ws in $(seq 2 20); do
        echo "    { workspace = \"$ws\"; monitor = \"desc:$primary_desc\"; }"
      done
      echo "  ];"
      echo "}"
    } > "$MONITORS_FILE"

    echo "Written to $MONITORS_FILE"
    echo "Run 'rebuild' to apply."
  '';
}
