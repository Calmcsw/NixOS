{
  inputs,
  host,
  pkgs,
  ...
}:
let
  terminals = (import ../../../../../../hosts/wsl/x86-64/${host}/variables.nix).terminals;
  terminal = builtins.head (pkgs.lib.splitString "," terminals);
in
{
  home-manager.sharedModules = [
    (_: {
      home.packages = with pkgs; [
        inputs.nixvim.packages.${stdenv.hostPlatform.system}.default
      ];
      xdg.desktopEntries = {
        "nvim" = {
          name = "Neovim wrapper";
          genericName = "Text Editor";
          comment = "Edit text files";
          exec = "${pkgs.${terminal}}/bin/${terminal} --class \"nvim-wrapper\" -e nvim %F";
          icon = "nvim";
          mimeType = [
            "text/plain"
            "text/x-makefile"
          ];
          categories = [
            "Development"
            "TextEditor"
          ];
          terminal = false; # Important: set to false since we're calling kitty directly
        };
      };
    })
  ];
}
