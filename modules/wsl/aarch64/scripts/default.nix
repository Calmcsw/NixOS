{
  pkgs,
  lib,
  host,
  config,
  ...
}:
let
  terminals = (import ../../../../hosts/wsl/aarch64/${host}/variables.nix).terminals;
  terminal = builtins.head (lib.splitString "," terminals);
in
let
  # Define your custom args once
  scriptArgs = {
    inherit
      host
      pkgs
      lib
      config
      terminal
      ;
  };

  scripts = [
    (import ./rebuild.nix scriptArgs)
    (import ./rollback.nix scriptArgs)
    (import ./launcher.nix scriptArgs)
    (import ./network.nix scriptArgs)
    (import ./tmux-sessionizer.nix scriptArgs)
    (import ./extract.nix scriptArgs)
    (import ./driverinfo.nix scriptArgs)
    (import ./underwatt.nix scriptArgs)
    (import ./nextcloud-hydrate.nix scriptArgs)
    # Add new scripts here as you create them
  ];
in
{
  environment.systemPackages = scripts;
}
