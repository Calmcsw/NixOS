{ pkgs, ... }:
{
  home-manager.sharedModules = [
    (_: {
      home.packages = with pkgs; [
        (discord.override {
          withVencord = true;
        })
      ];
      xdg.configFile."Vencord/themes/catppuccin-mocha.css".text = ''
        /**
        * @name Catppuccin Mocha
        * @author winston#0001
        * @version 0.2.0
        * @description Soothing pastel theme for Discord
        **/

        @import url("https://catppuccin.github.io/discord/dist/catppuccin-mocha-mauve.theme.css");

        /* Fix: Catppuccin sets -webkit-app-region: drag too broadly, which on
           native Wayland causes clicks to register as window-drag instead of
           UI interaction. Reset all drag regions — windows can still be moved
           via the compositor (SUPER+drag). */
        * {
          -webkit-app-region: no-drag !important;
        }
      '';
      xdg.configFile."Vencord/settings/settings.json".text = builtins.toJSON {
        autoUpdate = false;
        autoUpdateNotification = false;
        useQuickCss = true;
        enabledThemes = [ "catppuccin-mocha.css" ];
        frameless = false;
        transparent = false;
        winNativeTitleBar = false;
        plugins = {
          CommandsAPI.enabled = true;
          MessageAccessoriesAPI.enabled = true;
          UserSettingsAPI.enabled = true;
          AlwaysTrust.enabled = true;
          ClearURLs.enabled = true;
          CopyFileContents.enabled = true;
          CrashHandler.enabled = true;
          Experiments.enabled = true;
          FakeNitro.enabled = true;
          NoTrack = { enabled = true; disableAnalytics = true; };
          NSFWGateBypass.enabled = true;
          ReverseImageSearch.enabled = true;
          ShowHiddenThings.enabled = true;
          SilentTyping = {
            enabled = true;
            showIcon = true;
            contextMenu = true;
            isEnabled = false;
          };
          SpotifyCrack.enabled = true;
          YoutubeAdblock.enabled = true;
          EmoteCloner.enabled = true;
          MessageLogger = {
            enabled = true;
            logDeletes = true;
            collapseDeleted = false;
            logEdits = false;
            inlineEdits = false;
            ignoreBots = true;
            ignoreSelf = true;
          };
          ReplaceGoogleSearch = {
            enabled = true;
            customEngineName = "Startpage";
            customEngineURL = "https://www.startpage.com/sp/search?prfe=c602752472dd4a3d8286a7ce441403da08e5c4656092384ed3091a946a5a4a4c99962d0935b509f2866ff1fdeaa3c33a007d4d26e89149869f2f7d0bdfdb1b51aa7ae7f5f17ff4a233ff313d&query=";
          };
          Settings = { enabled = true; settingsLocation = "aboveNitro"; };
          SupportHelper.enabled = true;
        };
        notifications = {
          timeout = 5000;
          position = "bottom-right";
          useNative = "not-focused";
          logLimit = 50;
        };
        cloud = {
          authenticated = false;
          url = "https://api.vencord.dev/";
          settingsSync = false;
          settingsSyncVersion = 1737589382741;
        };
      };
    })
  ];
}
