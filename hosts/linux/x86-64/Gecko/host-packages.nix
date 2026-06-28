{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    #obsidian
    #ludusavi # For game saves
    #protonvpn-gui # VPN
    #github-desktop
    # pokego # Overlayed
    lua5_1
    lua51Packages.luarocks
    tree-sitter
  ];
}
