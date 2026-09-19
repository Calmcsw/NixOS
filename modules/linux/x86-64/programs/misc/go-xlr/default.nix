{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    goxlr-utility
    goxlr-utility-ui
    zenity
  ];

  services.udev.packages = [ pkgs.goxlr-utility ];

  home-manager.sharedModules = [
    (_: {
      systemd.user.services.goxlr-daemon = {
        Unit = {
          Description = "GoXLR Utility Daemon";
          After = [ "graphical-session.target" ];
          PartOf = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${pkgs.goxlr-utility}/bin/goxlr-daemon";
          Restart = "on-failure";
          RestartSec = 3;
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };

      systemd.user.services.goxlr-profile-load = {
        Unit = {
          Description = "Load GoXLR profile";
          After = [ "goxlr-daemon.service" ];
          BindsTo = [ "goxlr-daemon.service" ];
        };
        Service = {
          Type = "oneshot";
          # Wait for daemon to be ready, then load profile if it exists
          ExecStart = "${pkgs.bash}/bin/bash -c 'sleep 3 && if ${pkgs.goxlr-utility}/bin/goxlr-client profiles list 2>/dev/null | grep -q \"Default Green\"; then ${pkgs.goxlr-utility}/bin/goxlr-client profiles device load \"Default Green\"; fi'";
          RemainAfterExit = "yes";
          TimeoutStartSec = 15;
        };
        Install = {
          WantedBy = [ "goxlr-daemon.service" ];
        };
      };

      systemd.user.services.goxlr-ui = {
        Unit = {
          Description = "GoXLR Utility UI";
          After = [ "graphical-session.target" "goxlr-daemon.service" ];
          Requires = [ "goxlr-daemon.service" ];
          PartOf = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${pkgs.goxlr-utility-ui}/bin/goxlr-utility-ui";
          Restart = "on-failure";
          RestartSec = 5;
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };
    })
  ];

  home-manager.users.cathal = { config, lib, ... }: {
    home.activation.goXLRProfiles = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p "${config.home.homeDirectory}/documents/GoXLR/Profiles"
      mkdir -p "${config.home.homeDirectory}/.local/share/goxlr-utility"

      if [ ! -L "${config.home.homeDirectory}/.local/share/goxlr-utility/profiles" ]; then
        rm -rf "${config.home.homeDirectory}/.local/share/goxlr-utility/profiles"
        ln -s "${config.home.homeDirectory}/documents/GoXLR/Profiles" \
              "${config.home.homeDirectory}/.local/share/goxlr-utility/profiles"
      fi
    '';
  };
}
