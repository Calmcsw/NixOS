{
  pkgs,
  lib,
  inputs,
  host,
  ...
}:
let
  inherit (import ../../../../hosts/linux/aarch64/${host}/variables.nix)
    username
    editors
    terminals
    browsers
    shell
    ;
in
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];
  programs.dconf.enable = true; # Enable dconf for home-manager
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    overwriteBackup = true;
    backupFileExtension = "backup";
    users.${username} = {
      # Let Home Manager install and manage itself.
      programs.home-manager.enable = true;
      xdg = {
        enable = true;
        userDirs.setSessionVariables = true;
      };

      wayland.windowManager.hyprland.configType = "lua";

      programs.neovim = {
        withRuby = true;
        withPython3 = true;
      };

      programs.firefox.configPath = ".mozilla/firefox";

      gtk.gtk4.theme = null;

      home = {
        username = "${username}";
        homeDirectory = "/home/${username}";
        stateVersion = "23.11"; # Do not change!
        sessionVariables = {
          EDITOR =
            let
              editor = builtins.head (lib.splitString "," editors);
            in
            if (editor == "nixvim" || editor == "neovim" || editor == "nvchad") then
              "nvim"
            else if editor == "vscode" then
              "code"
            else
              "nano";
          BROWSER = builtins.head (lib.splitString "," browsers);
          TERMINAL = builtins.head (lib.splitString "," terminals);
        };
      };
    };
  };
  users = {
    mutableUsers = true;
    users.${username} = {
      isNormalUser = true;
      initialPassword = "123";
      extraGroups = [
        "wheel" # sudo access
        "input"
        "networkmanager"
        "video"
        "audio"
        "libvirtd"
        "kvm"
        "docker"
        "disk"
        "adbusers"
        "lp"
        "scanner"
        "vboxusers" # Virtual Box
      ];
      shell = pkgs.${shell};
      ignoreShellProgramCheck = true;
    };
  };
  nix.settings.allowed-users = [ "${username}" ];
}
