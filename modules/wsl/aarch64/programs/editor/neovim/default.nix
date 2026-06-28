{
  inputs,
  host,
  pkgs,
  ...
}:
let
  terminals = (import ../../../../../../hosts/wsl/aarch64/${host}/variables.nix).terminals;
  terminal = builtins.head (pkgs.lib.splitString "," terminals);
in
{
  environment.systemPackages = with pkgs; [
    gcc # to compile treesitter parsers
    nodejs
    nil
    nixfmt-tree
    ripgrep
    lua5_1
    lua51Packages.luarocks
    tree-sitter
  ]; # Dependencies
  home-manager.sharedModules = [
    (_: {
      programs.neovim.enable = true;
      programs.neovim.plugins = [
        pkgs.vimPlugins.nvim-treesitter.withAllGrammars
      ];
      xdg.configFile."nvim".source = inputs.neovim;
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
