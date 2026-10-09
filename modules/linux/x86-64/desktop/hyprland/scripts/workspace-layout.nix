{ pkgs, ... }:
let
  script = pkgs.writeShellScriptBin "workspace-layout" ''
    # Resolve home-manager packages (not in compositor PATH)
    zen_bin=$(which zen-beta 2>/dev/null || echo "/etc/profiles/per-user/$(whoami)/bin/zen-beta")
    discord_bin=$(which discord 2>/dev/null || echo "/etc/profiles/per-user/$(whoami)/bin/discord")
    code_bin=$(which code 2>/dev/null || echo "/etc/profiles/per-user/$(whoami)/bin/code")

    # Layout definition — edit here to add/remove/move apps
    #   CLASSES[i]  — Hyprland window class
    #   WS[i]       — target workspace number
    #   FULL[i]     — open fullscreen (true/false)
    CLASSES=( "com.mitchellh.ghostty" "zen-beta" "org.signal.Signal"       "io.github.tobagin.karere"      "thunderbird" "discord"      "brave-browser" "dev.deedles.Trayscale"      "ivpn" "code"    "obsidian" )
    WS=(       1                       2          3                         3                               4             5              6               7                            7      8         9          )
    FULL=(     true                    true       false                     false                           true          true           true            false                        false  true      true       )

    # Launch commands per class — declared after variable resolution above
    declare -A CMD
    CMD["com.mitchellh.ghostty"]="${pkgs.ghostty}/bin/ghostty -e sh -c 'tmux new-session -A'"
    CMD["zen-beta"]="$zen_bin"
    CMD["org.signal.Signal"]="flatpak run org.signal.Signal"
    CMD["io.github.tobagin.karere"]="karere"
    CMD["thunderbird"]="thunderbird"
    CMD["discord"]="$discord_bin"
    CMD["brave-browser"]="brave"
    CMD["ivpn"]="ivpn-ui"
    CMD["dev.deedles.Trayscale"]="trayscale"
    CMD["code"]="$code_bin --disable-gpu"
    CMD["obsidian"]="obsidian"

    CLIENTS=$(hyprctl -j clients)
    TO_LAUNCH=()

    for i in "''${!CLASSES[@]}"; do
      class="''${CLASSES[$i]}"
      ws="''${WS[$i]}"
      fs="''${FULL[$i]}"
      cmd="''${CMD[$class]}"

      # Already on correct workspace — leave it
      if echo "$CLIENTS" | ${pkgs.jq}/bin/jq -e \
          --arg c "$class" --argjson w "$ws" \
          '.[] | select(.class == $c and .workspace.id == $w)' > /dev/null 2>&1; then
        continue
      fi

      # Running but on wrong workspace — move it
      if echo "$CLIENTS" | ${pkgs.jq}/bin/jq -e \
          --arg c "$class" \
          '.[] | select(.class == $c)' > /dev/null 2>&1; then
        hyprctl dispatch movetoworkspacesilent "$ws,class:^(''${class})$"
        continue
      fi

      # Not running — register window rule and queue for launch
      if [[ "$fs" == "true" ]]; then
        hyprctl eval "hl.window_rule({ [\"match\"] = { [\"class\"] = \"^(''${class})$\" }, [\"workspace\"] = \"''${ws} silent\", [\"fullscreen\"] = true })"
      else
        hyprctl eval "hl.window_rule({ [\"match\"] = { [\"class\"] = \"^(''${class})$\" }, [\"workspace\"] = \"''${ws} silent\" })"
      fi
      TO_LAUNCH+=("''${cmd}")
    done

    # Launch all apps after all rules are registered
    for cmd in "''${TO_LAUNCH[@]}"; do
      hyprctl eval "hl.exec_cmd([[''${cmd}]])"
    done

    # Focus workspace 1
    hyprctl eval 'hl.dsp.focus({ workspace = "1" })'

    # Clean up dynamic rules in background — Signal is slow to start so give it 20s
    (sleep 20 && hyprctl reload config-only -q) &
  '';

  desktopItem = pkgs.makeDesktopItem {
    name = "workspace-layout";
    desktopName = "Workspace Layout";
    comment = "Reset and launch workspace layout";
    exec = "${script}/bin/workspace-layout";
    icon = "preferences-system-windows";
    categories = [ "Utility" ];
  };
in
pkgs.symlinkJoin {
  name = "workspace-layout";
  paths = [ script desktopItem ];
  meta.mainProgram = "workspace-layout";
}
