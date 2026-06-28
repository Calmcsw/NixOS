{ host, pkgs, ... }:
pkgs.writeShellScriptBin "rebuild" ''
  # Colors for output
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  NC='\033[0m' # No Color

  if [[ $EUID -eq 0 ]]; then
    echo "This script should not be executed as root! Exiting..."
    exit 1
  fi

  if [ -f "$HOME/NixOS/flake.nix" ]; then
    flake=$HOME/NixOS
  elif [ -f "/etc/nixos/flake.nix" ]; then
    flake=/etc/nixos
  else
    echo "Error: flake not found. ensure flake.nix exists in either $HOME/NixOS or /etc/nixos"
    exit 1
  fi
  echo -e "''${GREEN}Flake: $flake''${NC}"
  echo -e "''${GREEN}Host: ${host}''${NC}"
  currentUser=$(logname)

  # replace username variable in variables.nix with $USER
  sudo sed -i -e "s/username = \".*\"/username = \"$currentUser\"/" "$flake/hosts/linux/x86-64/${host}/variables.nix"

  if [ -f "/etc/nixos/hardware-configuration.nix" ]; then
    cat "/etc/nixos/hardware-configuration.nix" | sudo tee "$flake/hosts/linux/x86-64/${host}/hardware-configuration.nix" >/dev/null
  else
    sudo nixos-generate-config --show-hardware-config >"$flake/hosts/linux/x86-64/${host}/hardware-configuration.nix"
  fi

  sudo git -C "$flake" add hosts/linux/x86-64/${host}/hardware-configuration.nix

  if [[ "$1" == "update" ]]; then
    echo -e "''${GREEN}Updating flake inputs...''${NC}"
    nix flake update "$flake"
  fi

  # nh os switch --hostname "${host}"
  sudo nixos-rebuild switch --flake "$flake#${host}"

  echo
  read -rsn1 -p"$(echo -e "''${GREEN}Press any key to continue''${NC}")"
''
