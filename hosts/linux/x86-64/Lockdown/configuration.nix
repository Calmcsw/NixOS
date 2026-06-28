{ lib, ... }:
let
  vars = import ./variables.nix;
in
{
  imports = [
    ./hardware-configuration.nix
    ./host-packages.nix

    # Core Modules (Don't change unless you know what you're doing)
    ../../../../modules/linux/x86-64/scripts
    ../../../../modules/linux/x86-64/core/boot.nix
    ../../../../modules/linux/x86-64/core/bash.nix
    ../../../../modules/linux/x86-64/core/zsh.nix
    ../../../../modules/linux/x86-64/core/starship.nix
    ../../../../modules/linux/x86-64/core/fonts.nix
    ../../../../modules/linux/x86-64/core/hardware.nix
    ../../../../modules/linux/x86-64/core/network.nix
    ../../../../modules/linux/x86-64/core/dns.nix
    ../../../../modules/linux/x86-64/core/nh.nix
    ../../../../modules/linux/x86-64/core/packages.nix
    ../../../../modules/linux/x86-64/core/printing.nix
    ../../../../modules/linux/x86-64/core/sddm.nix
    ../../../../modules/linux/x86-64/core/security.nix
    ../../../../modules/linux/x86-64/core/services.nix
    ../../../../modules/linux/x86-64/core/syncthing.nix
    ../../../../modules/linux/x86-64/core/system.nix
    ../../../../modules/linux/x86-64/core/users.nix
    ../../../../modules/linux/x86-64/core/nextcloud.nix
    # ../../../../modules/linux/x86-64/core/flatpak.nix
    # ../../../../modules/linux/x86-64/core/virtualisation.nix
    # ../../../../modules/linux/x86-64/core/dlna.nix

    # Optional
    ../../../../modules/linux/x86-64/hardware/drives # Automatically mount extra external/internal drives
    ../../../../modules/linux/x86-64/hardware/video/${vars.videoDriver}.nix # Enable gpu drivers defined in variables.nix
    ../../../../modules/linux/x86-64/desktop/${vars.desktop} # Set window manager defined in variables.nix
  ]
  ++ map (t: ../../../../modules/linux/x86-64/programs/terminal/${t}) (lib.splitString "," vars.terminals)
  ++ map (b: ../../../../modules/linux/x86-64/programs/browser/${b}) (lib.splitString "," vars.browsers)
  ++ map (e: ../../../../modules/linux/x86-64/programs/editor/${e}) (lib.splitString "," vars.editors)
  ++ map (f: ../../../../modules/linux/x86-64/programs/cli/${f}) (lib.splitString "," vars.tuiFileManagers)
  ++ [
    ../../../../modules/linux/x86-64/programs/misc/nautilus
    ../../../../modules/linux/x86-64/programs/cli/tmux
    ../../../../modules/linux/x86-64/programs/cli/direnv
    ../../../../modules/linux/x86-64/programs/cli/lazygit
    ../../../../modules/linux/x86-64/programs/cli/impala
    ../../../../modules/linux/x86-64/programs/cli/bluetui
    ../../../../modules/linux/x86-64/programs/cli/cava
    ../../../../modules/linux/x86-64/programs/cli/fastfetch
    ../../../../modules/linux/x86-64/programs/cli/btop
    ../../../../modules/linux/x86-64/programs/media/discord
    #../../../../modules/linux/x86-64/programs/media/spicetify
    ../../../../modules/linux/x86-64/programs/media/youtube-music
    ../../../../modules/linux/x86-64/programs/media/thunderbird
    # ../../../../modules/linux/x86-64/programs/media/obs-studio
    ../../../../modules/linux/x86-64/programs/media/mpv
    ../../../../modules/linux/x86-64/programs/media/vlc
    ../../../../modules/linux/x86-64/programs/misc/pinta
    ../../../../modules/linux/x86-64/programs/misc/localsend
    ../../../../modules/linux/x86-64/programs/misc/signal
    ../../../../modules/linux/x86-64/programs/misc/tlp
    ../../../../modules/linux/x86-64/programs/misc/thunar
    ../../../../modules/linux/x86-64/programs/misc/go-xlr
    ../../../../modules/linux/x86-64/programs/misc/system-utils
    ../../../../modules/linux/x86-64/programs/misc/libreoffice
    ../../../../modules/linux/x86-64/programs/misc/lact # GPU fan, clock and power configuration
  ]
  ++ lib.optional (vars.games == true) ../../../../modules/linux/x86-64/core/games.nix;

  hardware.ckb-next.enable = true;
}
