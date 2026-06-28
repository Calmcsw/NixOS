{ pkgs, ... }:
let
  dreamsofcode-io-catppuccin-tmux = pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = "catppuccin";
    version = "unstable-2023-01-06";
    src = pkgs.fetchFromGitHub {
      owner = "dreamsofcode-io";
      repo = "catppuccin-tmux";
      rev = "b4e0715356f820fc72ea8e8baf34f0f60e891718";
      sha256 = "sha256-FJHM6LJkiAwxaLd5pnAoF3a7AE1ZqHWoCpUJE0ncCA8=";
    };
  };
  resurrectNormalize = pkgs.writeShellScript "resurrect-normalize" ''
    f="$(readlink -f "$HOME/.tmux/resurrect/last")"
    [ -f "$f" ] || exit 0
    # Strip nix store paths, profile paths, and nvim wrapper args
    sed -i \
      -e 's| --cmd .*-vim-pack-dir||g' \
      -e 's|/etc/profiles/per-user/[^/]*/bin/||g' \
      -e 's|/nix/store/[^/]*/bin/||g' \
      "$f"
    # If pgrep found a child with a different name than tmux's pane_current_command
    # (e.g. wrapper scripts like .claude-wrapped), use pane_current_command instead.
    # Fields: $10=pane_command (tmux detection), $11=pane_full_command (pgrep output)
    awk 'BEGIN{FS=OFS="\t"} /^pane/ && $11 != ":" && $11 != ":" $10 {$11 = ":" $10} 1' \
      "$f" > "$f.tmp" && mv "$f.tmp" "$f"
  '';
  tmux-menus = pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = "tmux-menus";
    version = "v2.2.34";
    rtpFilePath = "menus.tmux";
    src = pkgs.fetchFromGitHub {
      owner = "jaclu";
      repo = "tmux-menus";
      rev = "f60e791e80d066ef7463ab2a746f5f89a5683dc0";
      sha256 = "sha256-KPP6g1RX/c269IzhQeMO14a58sewqdTCaKgD3wfvDiw=";
    };
  };
in
{
  home-manager.sharedModules = [
    (_: {
      programs.tmux = {
        enable = true;
        clock24 = true;
        keyMode = "vi";
        baseIndex = 1;
        # terminal = "screen-256color";
        terminal = "tmux-256color";
        historyLimit = 100000;
        plugins = with pkgs.tmuxPlugins; [
          #dreamsofcode-io-catppuccin-tmux

          {
            plugin = tmux-menus;
            extraConfig =
                ''
                    set -g @menus_location_x 'R'
                    set -g @menus_location_y 'S'
                    set -g @menus_use_cache 'No'
                    set -g @menus_config_file "~/.config/tmux/tmux.conf"
                '';
          }
          {
            plugin = catppuccin;
            extraConfig =
                ''
                    set -g @catppuccin_window_default_text "#W"
                    set -g @catppuccin_window_current_text "#W"
                    set -g @catppuccin_window_text "#W"
                '';
          }
          catppuccin
          #sensible
          vim-tmux-navigator

           {
             plugin = resurrect;
             extraConfig =
               ''
                  set -g @resurrect-processes ':all:'
                  set -g @resurrect-capture-pane-contents "on"
                  set -g @resurrect-strategy-vim 'session'
                  set -g @resurrect-strategy-nvim 'session'
                  set -g @resurrect-save-command-strategy 'pgrep'
                  set -g @resurrect-hook-post-save-all "${resurrectNormalize}"
               '';
           }
           {
             plugin = continuum;
             extraConfig = ''
               set -g @continuum-restore 'on'
               #set -g @continuum-boot 'on'
               set -g @continuum-save-interval '1'
               #set -g @continuum-systemd-start-cmd 'start-server'
             '';
           }
        ];
        extraConfig = ''
          unbind C-b
          set -g prefix C-a
          bind C-a send-prefix

          # Options
          unbind c
          bind c new-window -c "#{pane_current_path}"
          unbind %
          bind % split-window -h -c "#{pane_current_path}"
          unbind '"'
          bind '"' split-window -v -c "#{pane_current_path}"

          set -g update-environment "VSCODE_IPC_HOOK_CLI"

          #bind-key C-s run-shell '${pkgs.tmuxPlugins.resurrect}/share/tmux-plugins/resurrect/scripts/save.sh'

          set -s set-clipboard on
          #set -s get-clipboard both
          set -g allow-passthrough all

          set -g @catppuccin_flavour 'mocha'
          set -g mouse on
          #set -g allow-rename off
          set -g renumber-windows on
#          set -ga terminal-overrides ",*:Tc"

          # Tmux sessionizer
#          bind-key -r f run-shell "tmux neww tmux-sessionizer"

          # Tmux binds
#          bind r command-prompt "rename-window %%"
#          bind R source-file ~/.config/tmux/tmux.conf
#          bind S choose-session
#          bind u choose-session
#          bind w list-windows
#          bind * setw synchronize-panes
#          bind P set pane-border-status
#          bind -n C-M-c kill-pane
#          bind x swap-pane -D
#          bind z resize-pane -Z
#
#          # Select panes
#          bind h select-pane -L
#          bind l select-pane -R
#          bind k select-pane -U
#          bind j select-pane -D

          # Resize panes
          # bind -n M-h resize-pane -L 2
          # bind -n M-l resize-pane -R 2
          # bind -n M-k resize-pane -U 2
          # bind -n M-j resize-pane -D 2
#          bind -n M-Left resize-pane -L 2
#          bind -n M-Right resize-pane -R 2
#          bind -n M-Up resize-pane -U 2
#          bind -n M-Down resize-pane -D 2

          # Splits
#          bind | split-window -h -c "#{pane_current_path}"
#          bind [ split-window -h -c "#{pane_current_path}"
#          bind - split-window -v -c "#{pane_current_path}"
#          bind ] split-window -v -c "#{pane_current_path}"
#          bind c new-window -c "#{pane_current_path}"

          # Select windows
#          bind -n S-Left  previous-window
#          bind -n S-Right next-window

#          bind -n C-M-h  previous-window
#          bind -n C-M-l next-window

          # vi mode
#          bind-key -T copy-mode-vi v send-keys -X begin-selection
#          bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
#          bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel
        '';
      };
    })
  ];
}
