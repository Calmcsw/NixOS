{ pkgs, ... }:
{
  home-manager.sharedModules = [
    (_: {
      xdg.configFile."ghostty/themes/catppuccin-mocha".text = ''
        palette = 0=#45475a
        palette = 1=#f38ba8
        palette = 2=#a6e3a1
        palette = 3=#f9e2af
        palette = 4=#89b4fa
        palette = 5=#f5c2e7
        palette = 6=#94e2d5
        palette = 7=#bac2de
        palette = 8=#585b70
        palette = 9=#f38ba8
        palette = 10=#a6e3a1
        palette = 11=#f9e2af
        palette = 12=#89b4fa
        palette = 13=#f5c2e7
        palette = 14=#94e2d5
        palette = 15=#a6adc8
        background = 1e1e2e
        foreground = cdd6f4
        cursor-color = f5e0dc
        cursor-text = 1e1e2e
        selection-background = 45475a
        selection-foreground = cdd6f4
      '';

      programs.ghostty = {
        enable = true;
        package = pkgs.ghostty;
        settings = {
          theme = "catppuccin-mocha";
          font-family = "0xProto Nerd Font";
          font-size = 12;
          window-decoration = false;
          gtk-single-instance = false;
          background-opacity = 0.8;
          cursor-style = "block";
          cursor-style-blink = false;
          scrollback-limit = 10000;
          copy-on-select = false;
          window-padding-x = 0;
          window-padding-y = 0;
          window-padding-balance = true;
          window-padding-color = "background";
        };
      };
    })
  ];
}
