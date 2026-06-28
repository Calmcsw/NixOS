{ pkgs, ... }:
let
  script = pkgs.writeShellScriptBin "workspace-layout" ''
    # Kill windows only on the workspaces this script manages
    hyprctl -j clients | ${pkgs.jq}/bin/jq -r '.[] | select(.workspace.id | IN(1,2,3,4,5,6,8,9)) | .pid' | xargs -r kill 2>/dev/null
    sleep 0.5

    # Resolve home-manager packages (not in compositor PATH)
    zen_bin=$(which zen-beta 2>/dev/null || echo "/etc/profiles/per-user/$(whoami)/bin/zen-beta")
    discord_bin=$(which discord 2>/dev/null || echo "/etc/profiles/per-user/$(whoami)/bin/discord")
    code_bin=$(which code 2>/dev/null || echo "/etc/profiles/per-user/$(whoami)/bin/code")

    # Set temporary workspace rules (fullscreen for all except signal and whatsapp)
    hyprctl eval 'hl.window_rule({ ["match"] = { ["class"] = "^(com.mitchellh.ghostty)$" }, ["workspace"] = "1 silent", ["fullscreen"] = true })'
    hyprctl eval 'hl.window_rule({ ["match"] = { ["class"] = "^(zen-beta)$" },              ["workspace"] = "2 silent", ["fullscreen"] = true })'
    hyprctl eval 'hl.window_rule({ ["match"] = { ["class"] = "^(signal)$" },                ["workspace"] = "3 silent" })'
    hyprctl eval 'hl.window_rule({ ["match"] = { ["class"] = "^(whatsapp-electron)$" },     ["workspace"] = "3 silent" })'
    hyprctl eval 'hl.window_rule({ ["match"] = { ["class"] = "^(thunderbird)$" },           ["workspace"] = "4 silent", ["fullscreen"] = true })'
    hyprctl eval 'hl.window_rule({ ["match"] = { ["class"] = "^(discord)$" },               ["workspace"] = "5 silent", ["fullscreen"] = true })'
    hyprctl eval 'hl.window_rule({ ["match"] = { ["class"] = "^(brave-browser)$" },         ["workspace"] = "6 silent", ["fullscreen"] = true })'
    hyprctl eval 'hl.window_rule({ ["match"] = { ["class"] = "^(code)$" },                  ["workspace"] = "8 silent", ["fullscreen"] = true })'
    hyprctl eval 'hl.window_rule({ ["match"] = { ["class"] = "^(obsidian)$" },              ["workspace"] = "9 silent", ["fullscreen"] = true })'

    # Launch apps — ghostty/zen/discord/code need full paths; system packages work by name
    hyprctl eval "hl.exec_cmd([[${pkgs.ghostty}/bin/ghostty -e sh -c 'tmux new-session -A']])"
    hyprctl eval "hl.exec_cmd([[$zen_bin]])"
    hyprctl eval 'hl.exec_cmd([[signal-desktop]])'
    hyprctl eval 'hl.exec_cmd([[whatsapp-electron]])'
    hyprctl eval 'hl.exec_cmd([[thunderbird]])'
    hyprctl eval "hl.exec_cmd([[$discord_bin]])"
    hyprctl eval 'hl.exec_cmd([[brave]])'
    hyprctl eval "hl.exec_cmd([[$code_bin --disable-gpu]])"
    hyprctl eval 'hl.exec_cmd([[obsidian]])'

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
