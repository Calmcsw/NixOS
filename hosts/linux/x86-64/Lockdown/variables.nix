{
  username = "cathal"; # auto-set with install.sh, live-install.sh, and rebuild scripts.

  # Desktop Environment
  desktop = "hyprland"; # hyprland, i3, gnome, plasma6

  # Theme & Appearance
  bar = "hyprpanel"; # hyprpanel, waybar
  waybarTheme = "minimal"; # stylish, minimal
  sddmTheme = "catppuccin-mocha-mauve";
  sddmWallpaper = "nineish-catppuccin-mocha-alt.png";
  defaultWallpaper = "pixelart/PoolBar.jpg"; # Change with SUPER + SHIFT + W (Hyprland)
  hyprlockWallpaper = "pixelart/PoolBar.jpg";

  # Default Applications
  terminals = "ghostty,alacritty"; # comma-separated, first is default; e.g. "alacritty,kitty"
  editors = "neovim,vscode"; # comma-separated, first is default; e.g. "neovim,vscode"
  browsers = "zen-beta,firefox"; # comma-separated, first is default $BROWSER; e.g. "zen-beta,firefox"
  tuiFileManagers = "yazi"; # comma-separated, first is default; e.g. "yazi,lf"
  shell = "bash"; # zsh, bash
  games = true; # Enable/Disable gaming module

  # Hardware
  os = "linux";
  arch = "x86-64";
  hostname = "Lockdown";
  videoDriver = "nvidia"; # nvidia, amdgpu, intel
  bluetoothSupport = true; # Whether your motherboard supports bluetooth
  laptop = false;

  # Localization
  timezone = "Europe/London";
  locale = "en_GB.UTF-8";
  clock24h = true;
  kbdLayout = "us";
  kbdVariant = "";
  consoleKeymap = "us";
}
