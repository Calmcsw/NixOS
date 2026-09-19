{ config, pkgs, lib, ... }:
let
    username = "cathal";  # Your username
    userHome = config.users.users.${username}.home;
    nextcloudPath = "${userHome}/Nextcloud2";
in
{
  # Install Nextcloud client
  environment.systemPackages = [ pkgs.nextcloud-client ];

  home-manager.users.${username} = { config, lib, ... }: {
    systemd.user.services.nextcloud-client = {
      Unit = {
        Description = "Nextcloud desktop client";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.nextcloud-client}/bin/nextcloud --background";
        Restart = "on-failure";
        RestartSec = 3;
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
    # Set XDG directories to Nextcloud
    xdg.userDirs = {
      enable = true;
      createDirectories = true;

      documents = "${nextcloudPath}/documents";
      pictures = "${nextcloudPath}/pictures";
      music = "${nextcloudPath}/music";
      videos = "${nextcloudPath}/videos";

      # Keep these local
      desktop = "${userHome}/desktop";
      download = "${userHome}/downloads";
      publicShare = "${userHome}/public";
      templates = "${userHome}/templates";
    };

    # Create symlinks on every rebuild
    home.file = {
      "documents".source = config.lib.file.mkOutOfStoreSymlink "${nextcloudPath}/documents";
      "pictures".source = config.lib.file.mkOutOfStoreSymlink "${nextcloudPath}/pictures";
      "music".source = config.lib.file.mkOutOfStoreSymlink "${nextcloudPath}/music";
      "videos".source = config.lib.file.mkOutOfStoreSymlink "${nextcloudPath}/videos";
    };
  };

  # Create Nextcloud folders via system activation
  system.activationScripts.createNextcloudFolders = ''
    mkdir -p ${nextcloudPath}/{documents,pictures,music,videos}
    chown -R ${username}:users ${nextcloudPath}
  '';
}
