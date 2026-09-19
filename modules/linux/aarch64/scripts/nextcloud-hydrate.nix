{ pkgs, ... }:
pkgs.writeShellScriptBin "nextcloud-hydrate" ''
  set -euo pipefail

  SOCKET="/run/user/$(id -u)/Nextcloud/socket"

  usage() {
    echo "Usage: nextcloud-hydrate <file-or-directory> [file-or-directory...]"
    echo "  Hydrates Nextcloud VFS placeholder (.nextcloud) files."
    exit 1
  }

  [ $# -eq 0 ] && usage

  if [ ! -S "$SOCKET" ]; then
    echo "Error: Nextcloud socket not found at $SOCKET" >&2
    echo "Is the Nextcloud client running?" >&2
    exit 1
  fi

  hydrate_file() {
    local f="$1"
    if [[ "$f" != *.nextcloud ]]; then
      echo "Skipping (not a .nextcloud file): $f" >&2
      return
    fi
    printf "MAKE_AVAILABLE_LOCALLY:%s\n" "$f" \
      | ${pkgs.socat}/bin/socat - UNIX-CONNECT:"$SOCKET" > /dev/null
    echo "Hydrating: $f"
  }

  for target in "$@"; do
    if [ -f "$target" ]; then
      hydrate_file "$target"
    elif [ -d "$target" ]; then
      while IFS= read -r -d "" f; do
        hydrate_file "$f"
      done < <(${pkgs.findutils}/bin/find "$target" -name "*.nextcloud" -print0)
    else
      echo "Error: '$target' is not a file or directory" >&2
      exit 1
    fi
  done
''
