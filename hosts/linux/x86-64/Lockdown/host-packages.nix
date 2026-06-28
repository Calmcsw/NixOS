{ pkgs, inputs, lib, ... }:
{
  environment.systemPackages = with pkgs; [
    obsidian
    github-desktop
    # pokego # Overlayed
    prismlauncher
    whatsapp-electron
    deskflow
    brave
    easyeffects
    procps
    zoom-us
    #lua5_1
    #lua51Packages.luarocks
    #tree-sitter
    inputs.nix-software-center.packages.${pkgs.stdenv.hostPlatform.system}.nix-software-center
    nordpass
    claude-code
  ];
}
