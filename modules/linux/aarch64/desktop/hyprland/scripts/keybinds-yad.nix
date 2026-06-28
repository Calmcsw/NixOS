{ pkgs, ... }:
pkgs.writeShellScriptBin "keybinds-yad" ''
  ${pkgs.procps}/bin/pkill -x yad 2>/dev/null

  ${pkgs.yad}/bin/yad \
    --center \
    --title="Hyprland Keybinds" \
    --no-buttons \
    --list \
    --width=820 \
    --height=960 \
    --expand-column=2 \
    --column=Key: \
    --column=Description: \
    --column=Command: \
    \
    "═══" "APPLICATIONS" "═══" \
    "SUPER Return"           "Launch terminal"              "ghostty" \
    "SUPER ALT Return"       "Launch tmux session picker"   "launcher tmux" \
    "SUPER SHIFT Return"     "Launch browser"               "zen-beta" \
    "SUPER SHIFT B"          "Launch browser"               "zen-beta" \
    "SUPER SHIFT ALT B"      "Launch browser (incognito)"   "zen-beta --incognito" \
    "SUPER SHIFT F"          "Launch file manager"          "ghostty -e yazi" \
    "SUPER SHIFT N"          "Launch editor"                "code --disable-gpu" \
    "SUPER SHIFT S"          "Launch Spotify"               "spotify" \
    "SUPER SHIFT Y"          "Launch YouTube Music"         "youtube-music" \
    "SUPER CTRL T"           "System monitor"               "ghostty -e btop" \
    "SUPER A"                "App launcher"                 "launcher drun" \
    "SUPER SPACE"            "App launcher"                 "launcher drun" \
    "SUPER SHIFT W"          "Wallpaper picker"             "launcher wallpaper" \
    "SUPER CTRL E"           "Emoji picker"                 "launcher emoji" \
    "SUPER SHIFT T"          "tmux session picker"          "launcher tmux" \
    "SUPER CTRL G"           "Game launcher"                "launcher games" \
    "SUPER M"                "Music picker (rofi)"          "rofimusic" \
    "SUPER U"                "Rebuild system"               "ghostty -e rebuild" \
    "SUPER CTRL W"           "Wi-Fi manager"                "iwgtk" \
    "CTRL ALT M"             "Microfetch"                   "microfetch" \
    \
    "═══" "WINDOW" "═══" \
    "SUPER W"                "Close window"                 "window.close" \
    "SUPER Q"                "Close window"                 "window.close" \
    "ALT F4"                 "Force kill window"            "window.kill" \
    "SUPER T"                "Toggle floating"              "window.float toggle" \
    "SUPER F"                "Fullscreen"                   "window.fullscreen" \
    "SUPER ALT F"            "Maximize"                     "fullscreen mode=maximized" \
    "SUPER CTRL F"           "Fake fullscreen"              "fullscreen_state internal=0 client=2" \
    "SUPER P"                "Toggle pseudo tiling"         "window.pseudo" \
    "SUPER J"                "Toggle split"                 "layout togglesplit" \
    "SUPER L"                "Toggle workspace layout"      "toggle-layout" \
    "SUPER BACKSPACE"        "Toggle window transparency"   "opaque toggle" \
    "SUPER SHIFT BACKSPACE"  "Toggle all gaps/borders"      "toggle-gaps" \
    "SUPER O"                "Pop window out (float + pin)" "window-pop" \
    "SUPER G"                "Toggle window group"          "group.toggle" \
    "SUPER SHIFT G"          "Toggle window group"          "group.toggle" \
    "SUPER ALT G"            "Move window out of group"     "window.move out_of_group" \
    "SUPER LMB drag"         "Move window with mouse"       "window.drag" \
    "SUPER RMB drag"         "Resize window with mouse"     "window.resize" \
    \
    "═══" "RESIZE" "═══" \
    "SUPER -"                "Resize narrower (-100px)"     "window.resize x=-100" \
    "SUPER ="                "Resize wider (+100px)"        "window.resize x=+100" \
    "SUPER SHIFT -"          "Resize shorter (-100px)"      "window.resize y=-100" \
    "SUPER SHIFT ="          "Resize taller (+100px)"       "window.resize y=+100" \
    "SUPER ALT -"            "Resize narrower (-25px)"      "window.resize x=-25" \
    "SUPER ALT ="            "Resize wider (+25px)"         "window.resize x=+25" \
    "SUPER SHIFT ALT -"      "Resize shorter (-25px)"       "window.resize y=-25" \
    "SUPER SHIFT ALT ="      "Resize taller (+25px)"        "window.resize y=+25" \
    "SUPER CTRL -"           "Resize narrower (-300px)"     "window.resize x=-300" \
    "SUPER CTRL ="           "Resize wider (+300px)"        "window.resize x=+300" \
    "SUPER CTRL SHIFT -"     "Resize shorter (-300px)"      "window.resize y=-300" \
    "SUPER CTRL SHIFT ="     "Resize taller (+300px)"       "window.resize y=+300" \
    \
    "═══" "FOCUS" "═══" \
    "SUPER ←"                "Focus left"                   "focus direction=l" \
    "SUPER →"                "Focus right"                  "focus direction=r" \
    "SUPER ↑"                "Focus up"                     "focus direction=u" \
    "SUPER ↓"                "Focus down"                   "focus direction=d" \
    "ALT Tab"                "Cycle next window"            "window.cycle_next" \
    "ALT SHIFT Tab"          "Cycle previous window"        "window.cycle_next prev" \
    \
    "═══" "SWAP / MOVE" "═══" \
    "SUPER SHIFT ←"          "Swap window left"             "window.swap l" \
    "SUPER SHIFT →"          "Swap window right"            "window.swap r" \
    "SUPER SHIFT ↑"          "Swap window up"               "window.swap u" \
    "SUPER SHIFT ↓"          "Swap window down"             "window.swap d" \
    "SUPER CTRL ALT →"       "Move win to next workspace"   "window.move r+1" \
    "SUPER CTRL ALT ←"       "Move win to prev workspace"   "window.move r-1" \
    \
    "═══" "GROUPS" "═══" \
    "SUPER CTRL ←"           "Previous tab in group"        "group.prev" \
    "SUPER CTRL →"           "Next tab in group"            "group.next" \
    "SUPER ALT ←"            "Move window into left group"  "window.move into_group=l" \
    "SUPER ALT →"            "Move window into right group" "window.move into_group=r" \
    "SUPER ALT ↑"            "Move window into upper group" "window.move into_group=u" \
    "SUPER ALT ↓"            "Move window into lower group" "window.move into_group=d" \
    "SUPER ALT Tab"          "Next window in group"         "group.next" \
    "SUPER ALT SHIFT Tab"    "Prev window in group"         "group.prev" \
    \
    "═══" "WORKSPACES" "═══" \
    "SUPER 1-9"              "Switch to workspace 1-9"      "focus workspace N" \
    "SUPER SHIFT 1-9"        "Move window to workspace 1-9" "window.move workspace N" \
    "SUPER CTRL 1-9"         "Move silently to ws 1-9"      "window.move workspace N silent" \
    "SUPER ALT 1-9"          "Switch to workspace 11-19"    "focus workspace N+10" \
    "SUPER Tab"              "Next non-empty workspace"     "focus workspace e+1" \
    "SUPER SHIFT Tab"        "Prev non-empty workspace"     "focus workspace e-1" \
    "SUPER CTRL Tab"         "Previous workspace"           "focus workspace previous" \
    "SUPER CTRL ↓"           "Go to empty workspace"        "focus workspace empty" \
    "SUPER mouse_down"       "Next workspace"               "focus workspace e+1" \
    "SUPER mouse_up"         "Previous workspace"           "focus workspace e-1" \
    "SUPER SHIFT ALT ←"      "Workspace to left monitor"    "workspace.move monitor=l" \
    "SUPER SHIFT ALT →"      "Workspace to right monitor"   "workspace.move monitor=r" \
    "SUPER SHIFT ALT ↑"      "Workspace to upper monitor"   "workspace.move monitor=u" \
    "SUPER SHIFT ALT ↓"      "Workspace to lower monitor"   "workspace.move monitor=d" \
    \
    "═══" "MONITORS" "═══" \
    "CTRL ALT Tab"           "Focus next monitor"           "focus monitor=+1" \
    "CTRL ALT SHIFT Tab"     "Focus previous monitor"       "focus monitor=-1" \
    \
    "═══" "SCRATCHPAD" "═══" \
    "SUPER S"                "Toggle scratchpad"            "workspace.toggle_special" \
    "SUPER ALT S"            "Move to scratchpad"           "window.move workspace=special" \
    \
    "═══" "CLIPBOARD" "═══" \
    "SUPER C"                "Universal copy"               "send Ctrl+Insert" \
    "SUPER V"                "Universal paste"              "send Shift+Insert" \
    "SUPER X"                "Universal cut"                "send Ctrl+X" \
    "SUPER CTRL V"           "Clipboard history"            "clipmanager" \
    \
    "═══" "SCREENSHOTS" "═══" \
    "Print"                  "Screenshot (select area)"     "screenshot s" \
    "SUPER Print"            "Colour picker (hex)"          "hyprpicker --autocopy" \
    "ALT Print"              "Screen record (select area)"  "screen-record a" \
    "SUPER CTRL Print"       "Extract text via OCR"         "ocr-capture" \
    "SUPER SHIFT Print"      "Screenshot (frozen screen)"   "screenshot sf" \
    "SUPER ALT Print"        "Screenshot (all monitors)"    "screenshot p" \
    "SUPER SHIFT ALT Print"  "Toggle GPU screen recording"  "gsr-record" \
    "SUPER CTRL SHIFT P"     "Toggle webcam overlay"        "webcam-overlay" \
    "SUPER CTRL PERIOD"      "Transcode image or video"     "transcode" \
    \
    "═══" "NOTIFICATIONS" "═══" \
    "SUPER SHIFT Q"          "Toggle notification panel"    "swaync-client -t -sw" \
    "SUPER ,"                "Close latest notification"    "swaync-client -c" \
    "SUPER SHIFT ,"          "Clear all notifications"      "swaync-client -C" \
    "SUPER CTRL ,"           "Toggle Do Not Disturb"        "swaync-client -d" \
    \
    "═══" "SESSION" "═══" \
    "SUPER CTRL L"           "Lock screen"                  "hyprlock" \
    "SUPER ESCAPE"           "Power menu"                   "wlogout -b 4" \
    "SUPER Delete"           "Exit Hyprland"                "exit" \
    "SUPER SHIFT SPACE"      "Restart bar"                  "pkill hyprpanel; hyprpanel" \
    "SUPER CTRL SHIFT W"     "Reset workspace layout"       "workspace-layout" \
    "CTRL ALT Delete"        "Kill all windows"             "kill all PIDs" \
    \
    "═══" "ZOOM" "═══" \
    "SUPER CTRL Z"           "Zoom in"                      "zoom in" \
    "SUPER CTRL mouse_down"  "Zoom in"                      "zoom in" \
    "SUPER CTRL mouse_up"    "Zoom out"                     "zoom out" \
    "SUPER CTRL ALT Z"       "Reset zoom"                   "zoom reset" \
    \
    "═══" "TOGGLES" "═══" \
    "SUPER CTRL N"           "Toggle night mode (4000K)"    "toggle-nightlight" \
    "SUPER CTRL I"           "Toggle idle screen lock"      "toggle-idle" \
    "SUPER /"                "Cycle monitor scale up"       "cycle-monitor-scale" \
    "SUPER ALT /"            "Cycle monitor scale down"     "cycle-monitor-scale --reverse" \
    "SUPER F10"              "Cycle power profile"          "cycle-power-profile" \
    \
    "═══" "MEDIA" "═══" \
    "XF86AudioPlay"          "Play/Pause"                   "playerctl play-pause" \
    "XF86AudioPause"         "Play/Pause"                   "playerctl play-pause" \
    "XF86AudioNext"          "Next track"                   "playerctl next" \
    "XF86AudioPrev"          "Previous track"               "playerctl previous" \
    "XF86AudioMute"          "Mute audio"                   "pamixer -t" \
    "SUPER XF86AudioMute"    "Cycle audio output device"    "audio-switch" \
    "XF86AudioMicMute"       "Mute microphone"              "pamixer --default-source -t" \
    "XF86AudioLowerVolume"   "Volume down (-2%)"            "pamixer -d 2" \
    "XF86AudioRaiseVolume"   "Volume up (+2%)"              "pamixer -i 2" \
    "ALT XF86AudioLowerVolume" "Volume down precise (-1%)"  "pamixer -d 1" \
    "ALT XF86AudioRaiseVolume" "Volume up precise (+1%)"    "pamixer -i 1" \
    "XF86MonBrightnessDown"  "Brightness down (-2%)"        "brightnessctl set 2%-" \
    "XF86MonBrightnessUp"    "Brightness up (+2%)"          "brightnessctl set +2%" \
    "ALT XF86MonBrightnessDown" "Brightness down precise"   "brightnessctl set 1%-" \
    "ALT XF86MonBrightnessUp"   "Brightness up precise"     "brightnessctl set +1%" \
    "SHIFT XF86MonBrightnessUp"   "Brightness maximum"      "brightnessctl set 100%" \
    "SHIFT XF86MonBrightnessDown" "Brightness minimum"      "brightnessctl set 1%" \
    "xf86Sleep"              "Suspend system"               "systemctl suspend" \
    \
    "═══" "REMINDERS" "═══" \
    "SUPER CTRL R"           "Set a reminder (via prompt)"  "reminder <min>" \
    "SUPER CTRL ALT R"       "Show upcoming reminders"      "reminder show" \
    "SUPER CTRL SHIFT R"     "Clear all reminders"          "reminder clear" \
    \
    "═══" "MISC" "═══" \
    "SUPER K"                "This keybind guide"           "keybinds-yad" \
    "SUPER ALT K"            "Switch keyboard layout"       "keyboardswitch" \
    "SUPER SHIFT ALT G"      "Enable game mode"             "gamemode" \
    "SUPER F8"               "Toggle auto-clicker (40cps)"  "autoclicker --cps 40"
''
