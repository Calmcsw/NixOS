# 💫 https://github.com/LinuxBeginnings 💫 #

#!/usr/bin/env bash
clear

printf "\n%.0s" {1..2}
echo -e "\e[35m
	╦╔═┌─┐┌─┐╦    ╦ ╦┬ ┬┌─┐┬─┐┬  ┌─┐┌┐┌┌┬┐
	╠╩╗│ ││ │║    ╠═╣└┬┘├─┘├┬┘│  ├─┤│││ ││ 2025
	╩ ╩└─┘└─┘╩═╝  ╩ ╩ ┴ ┴  ┴└─┴─┘┴ ┴┘└┘─┴┘ 
\e[0m"
printf "\n%.0s" {1..1}

# Set some colors for output messages
OK="$(tput setaf 2)[OK]$(tput sgr0)"
ERROR="$(tput setaf 1)[ERROR]$(tput sgr0)"
NOTE="$(tput setaf 3)[NOTE]$(tput sgr0)"
INFO="$(tput setaf 4)[INFO]$(tput sgr0)"
WARN="$(tput setaf 1)[WARN]$(tput sgr0)"
CAT="$(tput setaf 6)[ACTION]$(tput sgr0)"
MAGENTA="$(tput setaf 5)"
ORANGE="$(tput setaf 214)"
WARNING="$(tput setaf 1)"
YELLOW="$(tput setaf 3)"
GREEN="$(tput setaf 2)"
BLUE="$(tput setaf 4)"
SKY_BLUE="$(tput setaf 6)"
RESET="$(tput sgr0)"

set -e

# Common installer functions
#if [ -f "scripts/lib/install-common.sh" ]; then
#    # shellcheck source=/dev/null
#    . "scripts/lib/install-common.sh"
#fi

if [ -n "$(grep -i nixos </etc/os-release)" ]; then
    echo "${OK} Verified this is NixOS."
    echo "-----"
else
    echo "$ERROR This is not NixOS or the distribution information is not available."
    exit 1
fi

if command -v git &>/dev/null; then
    echo "$OK Git is installed, continuing with installation."
    echo "-----"
else
    echo "$ERROR Git is not installed. Please install Git and try again."
    echo "Example: nix-shell -p git"
    exit 1
fi

# Check for pciutils (lspci)
if ! command -v lspci >/dev/null 2>&1; then
    echo "$ERROR pciutils is not installed. Please install pciutils and try again."
    echo "Example: nix-shell -p pciutils"
    exit 1
fi

# Check Go version (from nixpkgs or local) for waybar-weather
if type nhl_check_go_version >/dev/null 2>&1; then
    nhl_check_go_version
fi

echo "$NOTE Ensure In Home Directory"
cd || exit

echo "-----"

backupname=$(date "+%Y-%m-%d-%H-%M-%S")
if [ -d "NixOS" ]; then
    echo "$NOTE NixOS exists, backing up to NixOS-backups directory."
    if [ -d "NixOS-backups" ]; then
        echo "Moving current version of NixOS to backups directory."
        sudo mv "$HOME"/NixOS NixOS-backups/"$backupname"
        sleep 1
    else
        echo "$NOTE Creating the backups directory & moving NixOS to it."
        mkdir -p NixOS-backups
        sudo mv "$HOME"/NixOS NixOS-backups/"$backupname"
        sleep 1
    fi
else
    echo "$OK Thank you for choosing NixOS"
fi

echo "-----"

echo "$NOTE Cloning & Entering NixOS Repository"
git clone --depth 1 https://github.com/Calmcsw/NixOS.git ~/NixOS
cd ~/NixOS || exit

printf "\n%.0s" {1..2}

echo "-----"

sudo -u $USER ./install.sh
