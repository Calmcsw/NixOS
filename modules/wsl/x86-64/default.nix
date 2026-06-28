{ host, lib, ... }:
let
  vars = import ../../../hosts/wsl/x86-64/${host}/variables.nix;
in
{
  imports = [
    ./scripts
    ./core/bash.nix
    ./core/zsh.nix
    ./core/starship.nix
    ./core/fonts.nix
    ./core/hardware.nix
    ./core/network.nix
    ./core/nh.nix
    ./core/packages.nix
    ./core/security.nix
    ./core/services.nix
    ./core/syncthing.nix
    ./core/system.nix
    ./core/users.nix
    # ./core/flatpak.nix
    # ./core/dlna.nix
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
    ./programs/misc/thunar
    ./programs/misc/ocr
    ./programs/misc/reminders
    ./programs/misc/transcode
  ];
}
