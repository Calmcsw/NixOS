{
  host,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) getExe getExe';
  lua = lib.generators.mkLuaInline;
  termExe = getExe pkgs.${builtins.head (lib.splitString "," terminals)};
  browserCmd = builtins.head (lib.splitString "," browsers);
  tuiFileManagerName = builtins.head (lib.splitString "," tuiFileManagers);
  fileManagerCmd = "${termExe} --class \"tuiFileManager\" -e ${tuiFileManagerName}";
  editorCmd = "code --disable-gpu";
  dsp = {
    exec        = cmd: lua "hl.dsp.exec_cmd([[${cmd}]])";
    close       = lua "hl.dsp.window.close()";
    kill        = lua "hl.dsp.window.kill()";
    exit        = lua "hl.dsp.exit()";
    float       = lua ''hl.dsp.window.float({ action = "toggle" })'';
    fullscreen  = lua "hl.dsp.window.fullscreen()";
    pseudo      = lua "hl.dsp.window.pseudo()";
    pin         = lua "hl.dsp.window.pin()";
    layout      = msg: lua ''hl.dsp.layout("${msg}")'';
    focus       = dir: lua ''hl.dsp.focus({ direction = "${dir}" })'';
    focusWs     = ws:  lua ''hl.dsp.focus({ workspace = "${toString ws}" })'';
    moveToWs    = ws:  lua ''hl.dsp.window.move({ workspace = "${toString ws}" })'';
    moveSilentWs = ws: lua ''hl.dsp.window.move({ workspace = "${toString ws}", follow = false })'';
    moveWin     = dir: lua ''hl.dsp.window.move({ direction = "${dir}" })'';
    swapWin     = dir: lua ''hl.dsp.window.swap({ direction = "${dir}" })'';
    cycleNext   = lua "hl.dsp.window.cycle_next()";
    bringToTop  = lua "hl.dsp.window.bring_to_top()";
    toggleGroup = lua "hl.dsp.group.toggle()";
    drag        = lua "hl.dsp.window.drag()";
    resizeMouse = lua "hl.dsp.window.resize()";
  };
  mk     = keys: disp:       { _args = [ keys disp ]; };
  mkOpts = keys: disp: opts: { _args = [ keys disp opts ]; };
  inherit (import ../../../../../hosts/linux/x86-64/${host}/variables.nix)
    bar
    waybarTheme
    browsers
    terminals
    tuiFileManagers
    kbdLayout
    kbdVariant
    defaultWallpaper
    ;
  inherit (import ../../../../../hosts/linux/x86-64/${host}/monitors.nix) monitors workspaces;

  # Import script modules
  # autowaybar = pkgs.callPackage ./scripts/autowaybar.nix { };
  update-monitors = pkgs.callPackage ./scripts/update-monitors.nix { };
  autoclicker = pkgs.callPackage ./scripts/autoclicker.nix { };
  batterynotify = pkgs.callPackage ./scripts/batterynotify.nix { };
  clipmanager = pkgs.callPackage ./scripts/clipmanager.nix { };
  gamemode = pkgs.callPackage ./scripts/gamemode.nix { };
  keyboardswitch = pkgs.callPackage ./scripts/keyboardswitch.nix { };
  keybinds-yad = pkgs.callPackage ./scripts/keybinds-yad.nix { };
  # keybinds-rofi = pkgs.callPackage ./scripts/keybinds-yad.nix { };
  # mediactrl = pkgs.callPackage ./scripts/mediactrl.nix { };
  rofimusic = pkgs.callPackage ./scripts/rofimusic.nix { };
  screen-record = pkgs.callPackage ./scripts/screen-record.nix { };
  screenshot = pkgs.callPackage ./scripts/screenshot.nix { };
  wallpaper = pkgs.callPackage ./scripts/wallpaper.nix { inherit defaultWallpaper; };
  zoom = pkgs.callPackage ./scripts/zoom.nix { };
  workspace-layout = pkgs.callPackage ./scripts/workspace-layout.nix { };
  toggle-idle = pkgs.callPackage ./scripts/toggle-idle.nix { };
  toggle-nightlight = pkgs.callPackage ./scripts/toggle-nightlight.nix { };
  cycle-monitor-scale = pkgs.callPackage ./scripts/cycle-monitor-scale.nix { };
  window-pop = pkgs.callPackage ./scripts/window-pop.nix { };
  webcam-overlay = pkgs.callPackage ./scripts/webcam-overlay.nix { };
  toggle-gaps = pkgs.writeShellScriptBin "toggle-gaps" ''
    current=$(hyprctl -j getoption general:gaps_in | ${pkgs.jq}/bin/jq -r '.int')
    if [ "$current" -eq 0 ]; then
      hyprctl keyword general:gaps_in 4
      hyprctl keyword general:gaps_out 9
      hyprctl keyword general:border_size 2
      hyprctl keyword decoration:rounding 10
    else
      hyprctl keyword general:gaps_in 0
      hyprctl keyword general:gaps_out 0
      hyprctl keyword general:border_size 0
      hyprctl keyword decoration:rounding 0
    fi
  '';
  toggle-layout = pkgs.writeShellScriptBin "toggle-layout" ''
    active=$(hyprctl activeworkspace -j | ${pkgs.jq}/bin/jq -r '.id')
    layout=$(hyprctl activeworkspace -j | ${pkgs.jq}/bin/jq -r '.tiledLayout')
    if [ "$layout" = "dwindle" ]; then new=scrolling; else new=dwindle; fi
    hyprctl eval "hl.workspace_rule({ workspace = \"$active\", layout = \"$new\" })" 2>/dev/null || \
      hyprctl keyword workspace "$active,layout:$new"
    notify-send -u low "Workspace layout: $new"
  '';
in
{
  imports = [
    ../../themes/Catppuccin # Catppuccin GTK and QT themes
    ./programs/wlogout
    ./programs/rofi
    ./programs/hypridle
    ./programs/hyprlock
  ]
  ++ lib.optional (bar == "hyprpanel") ./programs/hyprpanel
  ++ lib.optionals (bar == "waybar") [
    # ./programs/dunst
    ./programs/swaync
    ./programs/waybar/${waybarTheme}.nix
  ];

  environment.systemPackages = with pkgs; [
    pavucontrol
    swappy
    cliphist
    wl-clipboard
    v4l-utils
    update-monitors
    workspace-layout
    toggle-idle
    toggle-nightlight
    cycle-monitor-scale
    window-pop
    webcam-overlay
  ];

  systemd.user.services.hyprpolkitagent = {
    description = "Hyprpolkitagent - Polkit authentication agent";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };
  services.displayManager.defaultSession = "hyprland";

  programs.hyprland = {
    enable = true;
    package = pkgs.hyprland;
    # withUWSM = true;
  };

  home-manager.sharedModules = [
    (
      { config, ... }:
      {
        xdg.portal = {
          enable = true;
          extraPortals = with pkgs; [
            xdg-desktop-portal-gtk
          ];
          xdgOpenUsePortal = true;
          configPackages = [ config.wayland.windowManager.hyprland.package ];
          config.hyprland = {
            default = [
              "hyprland"
              "gtk"
            ];
            "org.freedesktop.impl.portal.OpenURI" = "gtk";
            "org.freedesktop.impl.portal.FileChooser" = "gtk";
            "org.freedesktop.impl.portal.Print" = "gtk";
          };
        };

        xdg.configFile."hypr/icons" = {
          source = ./icons;
          recursive = true;
        };

        # Set wallpaper
        services.awww.enable = true;

        #test later systemd.user.targets.hyprland-session.Unit.Wants = [ "xdg-desktop-autostart.target" ];
        wayland.windowManager.hyprland = {
          enable = true;
          package = pkgs.hyprland;
          plugins = [
            # inputs.hyprland-plugins.packages.${pkgs.stdenv.hostPlatform.system}.hyprwinwrap
            # inputs.hyprsysteminfo.packages.${pkgs.stdenv.hostPlatform.system}.default
          ];
          systemd = {
            enable = true;
            variables = [ "--all" ];
          };
          settings = {
            env = [
              { _args = [ "XDG_CURRENT_DESKTOP" "Hyprland" ]; }
              { _args = [ "XDG_SESSION_DESKTOP" "Hyprland" ]; }
              { _args = [ "XDG_SESSION_TYPE" "wayland" ]; }
              { _args = [ "GDK_BACKEND" "wayland,x11,*" ]; }
              { _args = [ "NIXOS_OZONE_WL" "1" ]; }
              { _args = [ "ELECTRON_OZONE_PLATFORM_HINT" "wayland" ]; }
              { _args = [ "MOZ_ENABLE_WAYLAND" "1" ]; }
              { _args = [ "OZONE_PLATFORM" "wayland" ]; }
              { _args = [ "EGL_PLATFORM" "wayland" ]; }
              { _args = [ "CLUTTER_BACKEND" "wayland" ]; }
              { _args = [ "SDL_VIDEODRIVER" "wayland" ]; }
              { _args = [ "QT_QPA_PLATFORM" "wayland;xcb" ]; }
              { _args = [ "QT_WAYLAND_DISABLE_WINDOWDECORATION" "1" ]; }
              { _args = [ "QT_QPA_PLATFORMTHEME" "qt6ct" ]; }
              { _args = [ "QT_AUTO_SCREEN_SCALE_FACTOR" "1" ]; }
              { _args = [ "QT_ENABLE_HIGHDPI_SCALING" "1" ]; }
              { _args = [ "WLR_RENDERER_ALLOW_SOFTWARE" "1" ]; }
              { _args = [ "NIXPKGS_ALLOW_UNFREE" "1" ]; }
            ];
            on = {
              _args = [
                "hyprland.start"
                (lua ''
                  function()
                    hl.exec_cmd("${lib.getExe wallpaper}")
                    hl.exec_cmd("${bar}")
                    hl.exec_cmd("swaync")
                    hl.exec_cmd("nm-applet --indicator")
                    hl.exec_cmd("iwgtk -i")
                    hl.exec_cmd("${getExe' pkgs.wl-clipboard "wl-paste"} --type text --watch cliphist store")
                    hl.exec_cmd("${getExe' pkgs.wl-clipboard "wl-paste"} --type image --watch cliphist store")
                    hl.exec_cmd("rm '$XDG_CACHE_HOME/cliphist/db'")
                    hl.exec_cmd("${getExe batterynotify}")
                    hl.exec_cmd("polkit-agent-helper-1")
                  end
                '')
              ];
            };
            config = {
              input = {
                kb_layout = "${kbdLayout},ru";
                kb_variant = "${kbdVariant},";
                repeat_delay = 275;
                repeat_rate = 35;
                numlock_by_default = true;
                follow_mouse = 1;
                touchpad.natural_scroll = false;
                tablet.output = "current";
                sensitivity = 0;
                force_no_accel = true;
              };
              general = {
                gaps_in = 4;
                gaps_out = 9;
                border_size = 2;
                col = {
                  active_border   = { colors = [ "rgba(ca9ee6ff)" "rgba(f2d5cfff)" ]; angle = 45; };
                  inactive_border = { colors = [ "rgba(b4befecc)" "rgba(6c7086cc)" ]; angle = 45; };
                };
                resize_on_border = true;
                layout = "dwindle";
              };
              decoration = {
                shadow.enabled = false;
                rounding = 10;
                dim_special = 0.3;
                blur = {
                  enabled = true;
                  special = true;
                  size = 6;
                  passes = 2;
                  new_optimizations = true;
                  ignore_opacity = true;
                  xray = false;
                };
              };
              group = {
                col = {
                  border_active          = { colors = [ "rgba(ca9ee6ff)" "rgba(f2d5cfff)" ]; angle = 45; };
                  border_inactive        = { colors = [ "rgba(b4befecc)" "rgba(6c7086cc)" ]; angle = 45; };
                  border_locked_active   = { colors = [ "rgba(ca9ee6ff)" "rgba(f2d5cfff)" ]; angle = 45; };
                  border_locked_inactive = { colors = [ "rgba(b4befecc)" "rgba(6c7086cc)" ]; angle = 45; };
                };
              };
              animations.enabled = true;
              misc = {
                disable_hyprland_logo = true;
                mouse_move_focuses_monitor = true;
                swallow_regex = "^(Alacritty|kitty)$";
                enable_swallow = true;
                vrr = 2;
                focus_on_activate = true;
                anr_missed_pings = 3;
              };
              cursor = {
                hide_on_key_press = true;
                warp_on_change_workspace = 1;
              };
              render.direct_scanout = 0;
              ecosystem = {
                no_update_news = true;
                no_donation_nag = true;
              };
              xwayland.force_zero_scaling = false;
              dwindle.preserve_split = true;
              master = {
                new_status = "master";
                new_on_top = true;
                mfact = 0.5;
              };
              binds = {
                workspace_back_and_forth = false;
                hide_special_on_workspace_change = true;
              };
            };
            layer_rule = [
              # Rofi
              { match.namespace = "rofi";                       blur = true; ignore_alpha = 0.7; }
              # Hyprpanel Menus
              { match.namespace = "^bar-.*$";                   blur = true; ignore_alpha = 0.7; }
              { match.namespace = "notifications-window";       blur = true; ignore_alpha = 0.7; }
              { match.namespace = "mediamenu";                  blur = true; ignore_alpha = 0.7; }
              { match.namespace = "notificationsmenu";          blur = true; ignore_alpha = 0.7; }
              { match.namespace = "calendarmenu";               blur = true; ignore_alpha = 0.7; }
              { match.namespace = "audiomenu";                  blur = true; ignore_alpha = 0.7; }
              { match.namespace = "networkmenu";                blur = true; ignore_alpha = 0.7; }
              { match.namespace = "energymenu";                 blur = true; ignore_alpha = 0.7; }
              { match.namespace = "dashboardmenu";              blur = true; ignore_alpha = 0.7; }
              # Swaync
              { match.namespace = "swaync-control-center";     blur = true; ignore_alpha = 0.7; }
              { match.namespace = "swaync-notification-window"; blur = true; ignore_alpha = 0.8; }
            ];
            curve = [
              { _args = [ "linear"        { type = "bezier"; points = [ [0    0   ] [1    1   ] ]; } ]; }
              { _args = [ "md3_standard"  { type = "bezier"; points = [ [0.2  0   ] [0    1   ] ]; } ]; }
              { _args = [ "md3_decel"     { type = "bezier"; points = [ [0.05 0.7 ] [0.1  1   ] ]; } ]; }
              { _args = [ "md3_accel"     { type = "bezier"; points = [ [0.3  0   ] [0.8  0.15] ]; } ]; }
              { _args = [ "overshot"      { type = "bezier"; points = [ [0.05 0.9 ] [0.1  1.1 ] ]; } ]; }
              { _args = [ "crazyshot"     { type = "bezier"; points = [ [0.1  1.5 ] [0.76 0.92] ]; } ]; }
              { _args = [ "hyprnostretch" { type = "bezier"; points = [ [0.05 0.9 ] [0.1  1.0 ] ]; } ]; }
              { _args = [ "fluent_decel"  { type = "bezier"; points = [ [0.1  1   ] [0    1   ] ]; } ]; }
              { _args = [ "easeInOutCirc" { type = "bezier"; points = [ [0.85 0   ] [0.15 1   ] ]; } ]; }
              { _args = [ "easeOutCirc"   { type = "bezier"; points = [ [0    0.55] [0.45 1   ] ]; } ]; }
              { _args = [ "easeOutExpo"   { type = "bezier"; points = [ [0.16 1   ] [0.3  1   ] ]; } ]; }
            ];
            animation = [
              { leaf = "windows";          enabled = true; speed = 3;   bezier = "md3_decel";    style = "popin 60%"; }
              { leaf = "border";           enabled = true; speed = 10;  bezier = "default"; }
              { leaf = "fade";             enabled = true; speed = 2.5; bezier = "md3_decel"; }
              { leaf = "workspaces";       enabled = true; speed = 3.5; bezier = "easeOutExpo";  style = "slide"; }
              { leaf = "specialWorkspace"; enabled = true; speed = 3;   bezier = "md3_decel";    style = "slidevert"; }
            ];
            gesture = [
              { fingers = 3; direction = "horizontal"; action = "workspace"; }
            ];
            window_rule = [
              { match.title = "(.*)(Godot)(.*)$";                                      tile = true; }

              # Opacity: browsers (full)
              { match.class = "^(firefox|Brave-browser|floorp|zen|zen-beta)$";         opacity = "1.0 1.0";  }
              # Opacity: 90/80
              { match.class = "^(Emacs)$";                                             opacity = "0.90 0.80"; }
              { match.class = "^(gcr-prompter)$";                                      opacity = "0.90 0.80"; }
              { match.title = "^(Hyprland Polkit Agent)$";                             opacity = "0.90 0.80"; }
              { match.class = "^(obsidian)$";                                          opacity = "0.90 0.80"; }
              { match.class = "^(proton.vpn.app.gtk)$";                               opacity = "0.90 0.80"; }
              { match.class = "^(heroic)$";                                            opacity = "0.90 0.80"; }
              { match.class = "^(Lutris|lutris|net.lutris.Lutris)$";                  opacity = "0.90 0.80"; }
              { match.class = "^(discord)$";                                           opacity = "0.90 0.80"; }
              { match.class = "^(WebCord)$";                                           opacity = "0.90 0.80"; }
              { match.class = "^(com.github.rafostar.Clapper)$";                      opacity = "0.90 0.80"; float = true; }
              # Opacity: 80/70
              { match.class = "^(kitty|alacritty|Alacritty|org.wezfurlong.wezterm)$"; opacity = "0.80 0.70"; }
              { match.class = "^(nvim-wrapper)$";                                      opacity = "0.80 0.70"; }
              { match.class = "^(gnome-disks)$";                                       opacity = "0.80 0.70"; }
              { match.class = "^(org.gnome.Nautilus|Thunar|thunar|pcmanfm)$";         opacity = "0.80 0.70"; }
              { match.class = "^(thunar-volman-settings)$";                            opacity = "0.80 0.70"; }
              { match.class = "^(org.gnome.FileRoller)$";                             opacity = "0.80 0.70"; }
              { match.class = "^(io.github.ilya_zlobintsev.LACT)$";                  opacity = "0.80 0.70"; }
              { match.class = "^(Steam|steam|steamwebhelper)$";                        opacity = "0.80 0.70"; }
              { match.class = "^(Spotify|spotify|com.github.th_ch.youtube_music)$";   opacity = "0.80 0.70"; }
              { match.title = "^(Kvantum Manager)$";                                   opacity = "0.80 0.70"; }
              { match.class = "^(VSCodium|codium-url-handler)$";                       opacity = "0.80 0.70"; }
              { match.class = "^(code|code-url-handler)$";                             opacity = "0.80 0.70"; }
              { match.class = "^(tuiFileManager)$";                                    opacity = "0.80 0.70"; }
              { match.class = "^(org.kde.dolphin)$";                                   opacity = "0.80 0.70"; }
              { match.class = "^(org.kde.ark)$";                                       opacity = "0.80 0.70"; float = true; }
              { match.class = "^(nwg-look)$";                                          opacity = "0.80 0.70"; float = true; }
              { match.class = "^(qt5ct|qt6ct)$";                                       opacity = "0.80 0.70"; }
              { match.class = "^(yad)$";                                               opacity = "0.80 0.70"; float = true; }
              { match.class = "^(gjs)$";                                               opacity = "0.80 0.70"; }
              { match.class = "^(com.github.tchx84.Flatseal)$";                       opacity = "0.80 0.70"; }
              { match.class = "^(hu.kramo.Cartridges)$";                              opacity = "0.80 0.70"; }
              { match.class = "^(com.obsproject.Studio)$";                             opacity = "0.80 0.70"; }
              { match.class = "^(gnome-boxes)$";                                       opacity = "0.80 0.70"; }
              { match.class = "^(app.drey.Warp)$";                                    opacity = "0.80 0.70"; float = true; }
              { match.class = "^(net.davidotek.pupgui2)$";                            opacity = "0.80 0.70"; float = true; }
              { match.class = "^(Signal)$";                                            opacity = "0.80 0.70"; float = true; }
              { match.class = "^(io.gitlab.theevilskeleton.Upscaler)$";               opacity = "0.80 0.70"; float = true; }
              { match.class = "^(pavucontrol)$";                                       opacity = "0.80 0.70"; float = true; }
              { match.class = "^(org.pulseaudio.pavucontrol)$";                       opacity = "0.80 0.70"; }
              { match.class = "^(blueman-manager)$";                                   opacity = "0.80 0.70"; float = true; }
              { match.class = "^(.blueman-manager-wrapped)$";                          opacity = "0.80 0.70"; float = true; }
              { match.class = "^(nm-applet)$";                                         opacity = "0.80 0.70"; float = true; }

              { match.class = "^(nm-connection-editor)$";                              opacity = "0.80 0.70"; float = true; }
              { match.class = "^(org.kde.polkit-kde-authentication-agent-1)$";         opacity = "0.80 0.70"; float = true; }

              # Picture-in-Picture: auto-float, pin across workspaces, fixed size, full opacity
              { match.title = "(Picture.?in.?[Pp]icture)"; float = true; pin = true; size = "600 338"; border_size = 0; opacity = "1 1"; }

              # Remaining float-only
              { match.class = "^(qt5ct)$"; float = true; }
              { match.class = "^(eog)$"; float = true; }

              # Games
              { match.tag = "games"; content = "game"; sync_fullscreen = true; fullscreen = true; border_size = 0; no_shadow = true; no_blur = true; no_anim = true; }
              { match.content = 3; tag = "+games"; }
              { match.class = "^(steam_app.*|steam_app_\\d+)$"; tag = "+games"; }
              { match.class = "^(gamescope)$";                   tag = "+games"; }
              { match.class = "(Waydroid)";                      tag = "+games"; }
              { match.class = "(osu!)";                          tag = "+games"; }

              # Microfetch
              { match.class = "^(microfetch)$"; opacity = "0.80 0.70"; float = true; center = true; size = "802 261"; }

              # Webcam overlay — float, pin, no border
              { match.title = "^(WebcamOverlay)$"; float = true; pin = true; border_size = 0; size = "360 203"; }
            ];
            bind =
              [
                # Keybinds help
                (mk "SUPER + K" (dsp.exec "${getExe keybinds-yad}"))
                (mk "SUPER + F8" (dsp.exec "kill $(cat /tmp/auto-clicker.pid) 2>/dev/null || ${getExe autoclicker} --cps 40"))

                # Night Mode / Idle / Monitor / Misc toggles
                (mk "SUPER + CTRL + N" (dsp.exec "${getExe toggle-nightlight}"))
                (mk "SUPER + CTRL + I" (dsp.exec "${getExe toggle-idle}"))
                (mk "SUPER + slash" (dsp.exec "${getExe cycle-monitor-scale}"))
                (mk "SUPER + ALT + slash" (dsp.exec "${getExe cycle-monitor-scale} --reverse"))
                (mk "SUPER + CTRL + SHIFT + P" (dsp.exec "${getExe webcam-overlay}"))
                (mk "SUPER + CTRL + PERIOD" (dsp.exec "transcode"))
                (mk "SUPER + F10" (dsp.exec "cycle-power-profile"))

                # Window/Session actions
                (mk "SUPER + W" dsp.close)
                (mk "SUPER + Q" dsp.close)
                (mk "ALT + F4" dsp.kill)
                (mk "SUPER + delete" dsp.exit)
                (mk "SUPER + T" dsp.float)
                (mk "SUPER + P" dsp.pseudo)
                (mk "SUPER + J" (dsp.layout "togglesplit"))
                (mk "SUPER + L" (dsp.exec "${getExe toggle-layout}"))
                (mk "SUPER + BACKSPACE" (dsp.exec "hyprctl dispatch setprop address:$(hyprctl -j activewindow | ${pkgs.jq}/bin/jq -r '.address') opaque toggle"))
                (mk "SUPER + SHIFT + BACKSPACE" (dsp.exec "${getExe toggle-gaps}"))
                (mk "SUPER + F" dsp.fullscreen)
                (mk "SUPER + ALT + F" (lua ''hl.dsp.window.fullscreen({ mode = "maximized" })''))
                (mk "SUPER + CTRL + F" (lua "hl.dsp.window.fullscreen_state({ internal = 0, client = 2 })"))
                (mk "SUPER + O" (dsp.exec "${getExe window-pop}"))
                (mk "SUPER + G" dsp.toggleGroup)
                (mk "SUPER + SHIFT + G" dsp.toggleGroup)
                (mk "SUPER + ALT + G" (lua "hl.dsp.window.move({ out_of_group = true })"))
                (mk "SUPER + CTRL + L" (dsp.exec "hyprlock"))
                (mk "SUPER + CTRL + W" (dsp.exec "iwgtk"))
                (mk "SUPER + CTRL + SHIFT + W" (dsp.exec "${lib.getExe workspace-layout}"))
                (mk "SUPER + ESCAPE" (dsp.exec "pkill -x wlogout || wlogout -b 4"))
                (mk "SUPER + SHIFT + SPACE" (dsp.exec "pkill waybar || pkill hyprpanel || ${bar}"))
                (mk "SUPER + CTRL + mouse_down" (dsp.exec "${getExe zoom} in"))
                (mk "SUPER + CTRL + mouse_up" (dsp.exec "${getExe zoom} out"))
                (mk "SUPER + CTRL + Z" (dsp.exec "${getExe zoom} in"))
                (mk "SUPER + CTRL + ALT + Z" (dsp.exec "${getExe zoom} reset"))

                # Notification controls (swaync equivalents of omarchy's mako binds)
                (mk "SUPER + comma" (dsp.exec "swaync-client -c"))
                (mk "SUPER + SHIFT + comma" (dsp.exec "swaync-client -C"))
                (mk "SUPER + CTRL + comma" (dsp.exec "swaync-client -d"))

                # Applications/Programs
                (mk "SUPER + Return"         (dsp.exec "${termExe}"))
                (mk "SUPER + ALT + Return"   (dsp.exec "launcher tmux"))
                (mk "SUPER + SHIFT + Return" (dsp.exec "${browserCmd}"))
                (mk "SUPER + SHIFT + B"      (dsp.exec "${browserCmd}"))
                (mk "SUPER + SHIFT + ALT + B" (dsp.exec "${browserCmd} --incognito"))
                (mk "SUPER + SHIFT + F"      (dsp.exec "${fileManagerCmd}"))
                (mk "SUPER + SHIFT + ALT + F" (dsp.exec "${fileManagerCmd}"))
                (mk "SUPER + SHIFT + N"      (dsp.exec "${editorCmd}"))
                (mk "SUPER + SHIFT + S"      (dsp.exec "spotify"))
                (mk "SUPER + SHIFT + Y"      (dsp.exec "youtube-music"))
                (mk "SUPER + CTRL + T"       (dsp.exec "${termExe} -e ${getExe pkgs.btop}"))
                (mk "CTRL + ALT + DELETE"    (dsp.exec "hyprctl -j clients | ${pkgs.jq}/bin/jq -r '.[].pid' | xargs -r kill 2>/dev/null"))
                (mk "CTRL + ALT + M"         (dsp.exec "${termExe} --class microfetch --hold -e microfetch"))

                (mk "SUPER + A"           (dsp.exec "launcher drun"))
                (mk "SUPER + SPACE"       (dsp.exec "launcher drun"))
                (mk "SUPER + SHIFT + W"   (dsp.exec "launcher wallpaper"))
                (mk "SUPER + CTRL + E"    (dsp.exec "launcher emoji"))
                (mk "SUPER + SHIFT + T"   (dsp.exec "launcher tmux"))
                (mk "SUPER + CTRL + G"    (dsp.exec "launcher games"))
                (mk "SUPER + ALT + K"     (dsp.exec "${getExe keyboardswitch}"))
                (mk "SUPER + SHIFT + Q"   (dsp.exec "swaync-client -t -sw"))
                (mk "SUPER + SHIFT + ALT + G" (dsp.exec "${getExe gamemode}"))
                (mk "SUPER + M"           (dsp.exec "${getExe rofimusic}"))

                # Universal clipboard (omarchy clipboard.lua — synthesises Ctrl/Shift+Insert)
                (mk "SUPER + C" (lua ''
                  function()
                    hl.dispatch(hl.dsp.send_key_state({ mods = "CTRL", key = "Insert", state = "down", window = "activewindow" }))
                    hl.timer(function()
                      hl.dispatch(hl.dsp.send_key_state({ mods = "CTRL", key = "Insert", state = "up", window = "activewindow" }))
                    end, { timeout = 50, type = "oneshot" })
                  end''))
                (mk "SUPER + V" (lua ''
                  function()
                    hl.dispatch(hl.dsp.send_key_state({ mods = "SHIFT", key = "Insert", state = "down", window = "activewindow" }))
                    hl.timer(function()
                      hl.dispatch(hl.dsp.send_key_state({ mods = "SHIFT", key = "Insert", state = "up", window = "activewindow" }))
                    end, { timeout = 50, type = "oneshot" })
                  end''))
                (mk "SUPER + X" (lua ''
                  function()
                    hl.dispatch(hl.dsp.send_key_state({ mods = "CTRL", key = "x", state = "down", window = "activewindow" }))
                    hl.timer(function()
                      hl.dispatch(hl.dsp.send_key_state({ mods = "CTRL", key = "x", state = "up", window = "activewindow" }))
                    end, { timeout = 50, type = "oneshot" })
                  end''))
                (mk "SUPER + CTRL + V" (dsp.exec "${getExe clipmanager}"))

                # Screenshot/Screencapture
                (mk "Print" (dsp.exec "${getExe screenshot} s"))
                (mk "SUPER + Print" (dsp.exec "${getExe pkgs.hyprpicker} --autocopy --format=hex"))
                (mk "ALT + Print" (dsp.exec "${getExe screen-record} a"))
                (mk "SUPER + SHIFT + Print" (dsp.exec "${getExe screenshot} sf"))
                (mk "SUPER + ALT + Print" (dsp.exec "${getExe screenshot} p"))
                (mk "SUPER + CTRL + Print" (dsp.exec "ocr-capture"))
                (mk "SUPER + SHIFT + ALT + Print" (dsp.exec "gsr-record"))

                # Functional keybinds
                (mk "xf86Sleep" (dsp.exec "systemctl suspend"))
                (mk "XF86AudioMicMute" (dsp.exec "${pkgs.pamixer}/bin/pamixer --default-source -t"))
                (mk "XF86AudioMute" (dsp.exec "${pkgs.pamixer}/bin/pamixer -t"))
                (mk "SUPER + XF86AudioMute" (dsp.exec "audio-switch"))
                (mk "XF86AudioPlay" (dsp.exec "${pkgs.playerctl}/bin/playerctl play-pause"))
                (mk "XF86AudioPause" (dsp.exec "${pkgs.playerctl}/bin/playerctl play-pause"))
                (mk "xf86AudioNext" (dsp.exec "${pkgs.playerctl}/bin/playerctl next"))
                (mk "xf86AudioPrev" (dsp.exec "${pkgs.playerctl}/bin/playerctl previous"))

                # Brightness / Volume (repeating)
                (mk "SUPER + CTRL + R" (dsp.exec "reminder"))
                (mk "SUPER + CTRL + ALT + R" (dsp.exec "reminder show"))
                (mk "SUPER + CTRL + SHIFT + R" (dsp.exec "reminder clear"))

                (mkOpts "XF86MonBrightnessDown"       (dsp.exec "${pkgs.brightnessctl}/bin/brightnessctl set 2%-") { repeating = true; })
                (mkOpts "XF86MonBrightnessUp"         (dsp.exec "${pkgs.brightnessctl}/bin/brightnessctl set +2%") { repeating = true; })
                (mkOpts "ALT + XF86MonBrightnessDown" (dsp.exec "${pkgs.brightnessctl}/bin/brightnessctl set 1%-") { repeating = true; })
                (mkOpts "ALT + XF86MonBrightnessUp"   (dsp.exec "${pkgs.brightnessctl}/bin/brightnessctl set +1%") { repeating = true; })
                (mk     "SHIFT + XF86MonBrightnessUp"   (dsp.exec "${pkgs.brightnessctl}/bin/brightnessctl set 100%"))
                (mk     "SHIFT + XF86MonBrightnessDown" (dsp.exec "${pkgs.brightnessctl}/bin/brightnessctl set 1%"))
                (mkOpts "XF86AudioLowerVolume"        (dsp.exec "${pkgs.pamixer}/bin/pamixer -d 2") { repeating = true; })
                (mkOpts "XF86AudioRaiseVolume"        (dsp.exec "${pkgs.pamixer}/bin/pamixer -i 2") { repeating = true; })
                (mkOpts "ALT + XF86AudioLowerVolume"  (dsp.exec "${pkgs.pamixer}/bin/pamixer -d 1") { repeating = true; })
                (mkOpts "ALT + XF86AudioRaiseVolume"  (dsp.exec "${pkgs.pamixer}/bin/pamixer -i 1") { repeating = true; })

                # Resize windows — x axis (repeating); y axis via Shift; small via Alt
                (mkOpts "SUPER + minus"               (lua "hl.dsp.window.resize({ x = -100, y = 0,    relative = true })") { repeating = true; })
                (mkOpts "SUPER + equal"               (lua "hl.dsp.window.resize({ x = 100,  y = 0,    relative = true })") { repeating = true; })
                (mkOpts "SUPER + SHIFT + minus"       (lua "hl.dsp.window.resize({ x = 0,    y = -100, relative = true })") { repeating = true; })
                (mkOpts "SUPER + SHIFT + equal"       (lua "hl.dsp.window.resize({ x = 0,    y = 100,  relative = true })") { repeating = true; })
                (mkOpts "SUPER + ALT + minus"         (lua "hl.dsp.window.resize({ x = -25,  y = 0,    relative = true })") { repeating = true; })
                (mkOpts "SUPER + ALT + equal"         (lua "hl.dsp.window.resize({ x = 25,   y = 0,    relative = true })") { repeating = true; })
                (mkOpts "SUPER + SHIFT + ALT + minus" (lua "hl.dsp.window.resize({ x = 0,    y = -25,  relative = true })") { repeating = true; })
                (mkOpts "SUPER + SHIFT + ALT + equal" (lua "hl.dsp.window.resize({ x = 0,    y = 25,   relative = true })") { repeating = true; })
                (mkOpts "SUPER + CTRL + minus"        (lua "hl.dsp.window.resize({ x = -300, y = 0,    relative = true })") { repeating = true; })
                (mkOpts "SUPER + CTRL + equal"        (lua "hl.dsp.window.resize({ x = 300,  y = 0,    relative = true })") { repeating = true; })
                (mkOpts "SUPER + CTRL + SHIFT + minus" (lua "hl.dsp.window.resize({ x = 0,   y = -300, relative = true })") { repeating = true; })
                (mkOpts "SUPER + CTRL + SHIFT + equal" (lua "hl.dsp.window.resize({ x = 0,   y = 300,  relative = true })") { repeating = true; })

                # Workspace tab navigation (omarchy: Tab = next/prev workspace, not window cycle)
                (mk "SUPER + Tab"             (lua ''hl.dsp.focus({ workspace = "e+1" })''))
                (mk "SUPER + SHIFT + Tab"     (lua ''hl.dsp.focus({ workspace = "e-1" })''))
                (mk "SUPER + CTRL + Tab"      (lua ''hl.dsp.focus({ workspace = "previous" })''))

                # Window cycling (Alt+Tab stays as window cycling)
                (mk "ALT + Tab"           dsp.cycleNext)
                (mk "ALT + Tab"           dsp.bringToTop)
                (mk "ALT + SHIFT + Tab"   (lua "hl.dsp.window.cycle_next({ next = false })"))
                (mk "ALT + SHIFT + Tab"   dsp.bringToTop)
                (mk "CTRL + ALT + Tab"    (lua ''hl.dsp.focus({ monitor = "+1" })''))
                (mk "CTRL + ALT + SHIFT + Tab" (lua ''hl.dsp.focus({ monitor = "-1" })''))

                # Group window navigation (omarchy: CTRL+left/right)
                (mk "SUPER + CTRL + left"  (lua "hl.dsp.group.prev()"))
                (mk "SUPER + CTRL + right" (lua "hl.dsp.group.next()"))
                # Go to first empty workspace (user custom — omarchy doesn't use CTRL+down)
                (mk "SUPER + CTRL + down" (lua ''hl.dsp.focus({ workspace = "empty" })''))

                # Move focus with arrow keys
                (mk "SUPER + left" (dsp.focus "l"))
                (mk "SUPER + right" (dsp.focus "r"))
                (mk "SUPER + up" (dsp.focus "u"))
                (mk "SUPER + down" (dsp.focus "d"))

                # Swap window positions
                (mk "SUPER + SHIFT + left" (dsp.swapWin "l"))
                (mk "SUPER + SHIFT + right" (dsp.swapWin "r"))
                (mk "SUPER + SHIFT + up" (dsp.swapWin "u"))
                (mk "SUPER + SHIFT + down" (dsp.swapWin "d"))

                # Mouse workspace switching
                (mk "SUPER + mouse:276" (lua ''hl.dsp.focus({ workspace = "5" })''))
                (mk "SUPER + mouse:275" (lua ''hl.dsp.focus({ workspace = "6" })''))
                (mk "SUPER + ALT + mouse:275" (lua ''hl.dsp.focus({ workspace = "7" })''))
                (mk "SUPER + SHIFT + mouse:276" (dsp.moveToWs "5"))
                (mk "SUPER + SHIFT + mouse:275" (dsp.moveToWs "6"))
                (mk "SUPER + SHIFT + ALT + mouse:275" (dsp.moveToWs "7"))
                (mk "SUPER + CTRL + mouse:276" (dsp.moveSilentWs "5"))
                (mk "SUPER + CTRL + mouse:275" (dsp.moveSilentWs "6"))
                (mk "SUPER + CTRL + ALT + mouse:275" (dsp.moveSilentWs "7"))

                # Rebuild NixOS
                (mk "SUPER + U" (dsp.exec "${termExe} -e rebuild"))

                # Scroll through existing workspaces
                (mk "SUPER + mouse_down" (lua ''hl.dsp.focus({ workspace = "e+1" })''))
                (mk "SUPER + mouse_up" (lua ''hl.dsp.focus({ workspace = "e-1" })''))

                # Move active window to a relative workspace
                (mk "SUPER + CTRL + ALT + right" (lua ''hl.dsp.window.move({ workspace = "r+1" })''))
                (mk "SUPER + CTRL + ALT + left" (lua ''hl.dsp.window.move({ workspace = "r-1" })''))

                # Move window into group in direction (omarchy: ALT+arrows)
                (mk "SUPER + ALT + left"  (lua ''hl.dsp.window.move({ into_group = "l" })''))
                (mk "SUPER + ALT + right" (lua ''hl.dsp.window.move({ into_group = "r" })''))
                (mk "SUPER + ALT + up"    (lua ''hl.dsp.window.move({ into_group = "u" })''))
                (mk "SUPER + ALT + down"  (lua ''hl.dsp.window.move({ into_group = "d" })''))

                # Move current workspace to monitor (omarchy: SHIFT+ALT+arrows)
                (mk "SUPER + SHIFT + ALT + left"  (lua ''hl.dsp.workspace.move({ monitor = "l" })''))
                (mk "SUPER + SHIFT + ALT + right" (lua ''hl.dsp.workspace.move({ monitor = "r" })''))
                (mk "SUPER + SHIFT + ALT + up"    (lua ''hl.dsp.workspace.move({ monitor = "u" })''))
                (mk "SUPER + SHIFT + ALT + down"  (lua ''hl.dsp.workspace.move({ monitor = "d" })''))

                # Group navigation
                (mk "SUPER + ALT + Tab"       (lua "hl.dsp.group.next()"))
                (mk "SUPER + ALT + SHIFT + Tab" (lua "hl.dsp.group.prev()"))
                (mk "SUPER + ALT + mouse_down" (lua "hl.dsp.group.next()"))
                (mk "SUPER + ALT + mouse_up"   (lua "hl.dsp.group.prev()"))

                # Special workspaces
                (mk "SUPER + ALT + S" (lua ''hl.dsp.window.move({ workspace = "special", follow = false })''))
                (mk "SUPER + S" (lua ''hl.dsp.workspace.toggle_special("")''))

                # Move/Resize windows with mouse drag
                (mkOpts "SUPER + mouse:272" dsp.drag { mouse = true; })
                (mkOpts "SUPER + mouse:273" dsp.resizeMouse { mouse = true; })
              ]
              ++ (builtins.concatLists (
                builtins.genList (
                  x:
                  let
                    ws = let c = (x + 1) / 10; in builtins.toString (x + 1 - (c * 10));
                  in
                  [
                    (mk "SUPER + ${ws}" (dsp.focusWs (x + 1)))
                    (mk "SUPER + SHIFT + ${ws}" (dsp.moveToWs (x + 1)))
                    (mk "SUPER + CTRL + ${ws}" (dsp.moveSilentWs (x + 1)))
                    (mk "SUPER + SHIFT + ALT + ${ws}" (dsp.moveSilentWs (x + 1)))
                  ]
                ) 10
              ))
              ++ (builtins.concatLists (
                builtins.genList (
                  x:
                  let
                    ws = let c = (x + 1) / 10; in builtins.toString (x + 1 - (c * 10));
                  in
                  [
                    (mk "SUPER + ALT + ${ws}" (dsp.focusWs (x + 11)))
                    (mk "SUPER + ALT + SHIFT + ${ws}" (dsp.moveToWs (x + 11)))
                    (mk "SUPER + ALT + CTRL + ${ws}" (dsp.moveSilentWs (x + 11)))
                  ]
                ) 10
              ));


            monitor = monitors;

            workspace_rule = workspaces;
          };
        };
      }
    )
  ];
}
