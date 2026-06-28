{
  pkgs,
  lib,
  host,
  ...
}:
let
  terminals = (import ../../../../../../../hosts/linux/aarch64/${host}/variables.nix).terminals;
  terminal = builtins.head (lib.splitString "," terminals);
  inherit (lib) getExe;
in
{
  home-manager.sharedModules = [
    (_: {
      programs.rofi = {
        enable = true;
        terminal = "${getExe pkgs.${terminal}}";
        plugins = with pkgs; [
          rofi-emoji # https://github.com/Mange/rofi-emoji 🤯
          rofi-games # https://github.com/Rolv-Apneseth/rofi-games 🎮
        ];
        extraConfig = import ./config.nix;
      };
      xdg.configFile."rofi/launchers" = {
        source = ./launchers;
        recursive = true;
      };
      xdg.configFile."rofi/colors" = {
        source = ./colors;
        recursive = true;
      };
    })
  ];
}
