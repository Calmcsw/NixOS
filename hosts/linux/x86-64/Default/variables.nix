{
  username = "railgun"; # auto-set with install.sh, live-install.sh, and rebuild scripts.

  # Desktop Environment
  desktop = "hyprland"; # hyprland, i3, gnome, plasma6

  # Theme & Appearance
  bar = "hyprpanel"; # hyprpanel, waybar
  waybarTheme = "minimal"; # stylish, minimal
  sddmTheme = "astronaut"; # astronaut, black_hole, purple_leaves, jake_the_dog, hyprland_kath
  sddmWallpaper = "nineish-catppuccin-mocha.png"; # filename without the 'nix-wallpaper-' prefix
  defaultWallpaper = "nix/nixos-wallpaper-catppuccin-frappe.png"; # Change with SUPER + SHIFT + W (Hyprland)
  hyprlockWallpaper = "nix/nixos-wallpaper-catppuccin-frappe.png"; # galaxy.webp was missing - restore when added

  # Default Applications
  terminals = "kitty"; # comma-separated, first is default; e.g. "alacritty,kitty"
  editors = "nixvim"; # comma-separated, first is default; e.g. "neovim,vscode"
  browsers = "zen-beta"; # comma-separated, first is default $BROWSER; e.g. "zen-beta,firefox"
  tuiFileManagers = "yazi"; # comma-separated, first is default; e.g. "yazi,lf"
  shell = "zsh"; # zsh, bash
  games = true; # Enable/Disable gaming module

  # Hardware
  os = "linux";
  arch = "x86-64";
  hostname = "Singularity";
  videoDriver = "nvidia"; # nvidia, amdgpu, intel
  bluetoothSupport = false; # Whether your motherboard supports bluetooth

  # Localization
  timezone = "Europe/London";
  locale = "en_GB.UTF-8";
  clock24h = true;
  kbdLayout = "gb";
  kbdVariant = "extd";
  consoleKeymap = "uk";
}
