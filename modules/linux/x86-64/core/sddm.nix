{
  pkgs,
  lib,
  host,
  ...
}:
let
  inherit (import ../../../../hosts/linux/x86-64/${host}/variables.nix) sddmTheme;
  inherit (import ../../../../hosts/linux/x86-64/${host}/variables.nix) sddmWallpaper;
  sddm-catppuccin = pkgs.catppuccin-sddm.override {
    flavor = "mocha";
    accent = "mauve";
    font  = "Noto Sans";
    fontSize = "9";
    background = "${../themes/wallpapers/nix/nix-wallpaper-${sddmWallpaper}}";
    loginBackground = true;
  };

  sddmDependencies = [
        sddm-catppuccin
        pkgs.kdePackages.qtsvg # Sddm Dependency
        pkgs.kdePackages.qtmultimedia # Sddm Dependency
        pkgs.kdePackages.qtvirtualkeyboard # Sddm Dependency
      ];
in
{
  services.displayManager = {
    sddm = {
      wayland.enable = true;
      enableHidpi = true;
      autoNumlock = true;
      package = lib.mkForce pkgs.kdePackages.sddm;
      extraPackages = sddmDependencies;
      settings.Theme.CursorTheme = "Bibata-Modern-Classic";
      enable = true;
      theme = "${sddmTheme}";
    };
  };

  environment.systemPackages = sddmDependencies;
}
