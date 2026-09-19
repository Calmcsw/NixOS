{ pkgs, ... }:
{
  services.gnome.gnome-keyring.enable = true;
  security = {
    rtkit.enable = true;
    polkit = {
      enable = true;
      extraConfig = ''
        polkit.addRule(function(action, subject) {
          if (action.id.indexOf("org.freedesktop.udisks2.") === 0 &&
              subject.local && subject.isInGroup("users")) {
            return polkit.Result.YES;
          }
        });
      '';
    };
    apparmor = {
      enable = true;
      killUnconfinedConfinables = true;
      packages = [ pkgs.apparmor-profiles ];
    };

    # Prevent replacing the running kernel without a reboot
    protectKernelImage = true;
    acme.acceptTerms = true;
  };
}
