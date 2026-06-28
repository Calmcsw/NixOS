{ host, ... }:
let
  inherit (import ../../../../hosts/linux/aarch64/${host}/variables.nix) username;
in
{
  services.syncthing = {
    enable = true;
    user = "${username}";
    dataDir = "/home/${username}";
    configDir = "/home/${username}/.config/syncthing";
  };
}
