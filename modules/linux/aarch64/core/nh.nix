{ host, pkgs, ... }:
let
  inherit (import ../../../../hosts/linux/aarch64/${host}/variables.nix) username;
in
{
  programs.nh = {
    enable = true;
    clean = {
      enable = true;
      extraArgs = "--keep-since 7d --keep 3";
    };
    flake = "/home/${username}/NixOS";
  };

  # environment.systemPackages = with pkgs; [
  #   nix-output-monitor
  #   nvd
  # ];
}
