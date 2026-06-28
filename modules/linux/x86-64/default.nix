{ host, lib, ... }:
let
  vars = import ../../../hosts/linux/x86-64/${host}/variables.nix;
in
{
  imports = [
    # Core Modules (Don't change unless you know what you're doing)
    ./scripts
    ./core/boot.nix
    ./core/bash.nix
    ./core/zsh.nix
    ./core/starship.nix
    ./core/fonts.nix
    ./core/hardware.nix
    ./core/network.nix
    ./core/nh.nix
    ./core/packages.nix
    ./core/printing.nix
    ./core/sddm.nix
    ./core/security.nix
    ./core/services.nix
    ./core/syncthing.nix
    ./core/system.nix
    ./core/users.nix
    # ./core/flatpak.nix
    # ./core/virtualisation.nix
    # ./core/dlna.nix

    # Optional
    ./hardware/drives
    ./hardware/video/${vars.videoDriver}.nix # Enable gpu drivers defined in variables.nix
    ./desktop/${vars.desktop} # Set window manager defined in variables.nix
  ]
  ++ map (t: ./programs/terminal/${t}) (lib.splitString "," vars.terminals)
  ++ map (b: ./programs/browser/${b}) (lib.splitString "," vars.browsers)
  ++ map (e: ./programs/editor/${e}) (lib.splitString "," vars.editors)
  ++ map (f: ./programs/cli/${f}) (lib.splitString "," vars.tuiFileManagers)
  ++ [
    ./programs/cli/tmux
    ./programs/cli/direnv
    ./programs/cli/lazygit
    ./programs/cli/cava
    ./programs/cli/btop
    ./programs/media/discord
    ./programs/media/spicetify
    # ./programs/media/youtube-music
    # ./programs/media/thunderbird
    # ./programs/media/obs-studio
    ./programs/media/mpv
    ./programs/misc/tlp
    ./programs/misc/thunar
    ./programs/misc/lact # GPU fan, clock and power configuration
    ./programs/misc/ocr
    ./programs/misc/reminders
    ./programs/misc/audio-switch
    ./programs/misc/gpu-screen-recorder
    ./programs/misc/power-profiles
    ./programs/misc/transcode
  ]
  ++ lib.optional (vars.games == true) ./core/games.nix;
}
