{ host, inputs, ... }:
let
  #inherit (import ../hosts/${host}/variables.nix) sddmTheme;
in
{
  # Overlay custom derivations into nixpkgs so you can use pkgs.<name>
  additions =
    final: _prev:
    import ../pkgs {
      pkgs = final;
      inherit host;
    };

  # https://wiki.nixos.org/wiki/Overlays
  modifications = final: prev: {
    nur = inputs.nur.overlays.default;
    xdg-desktop-portal-hyprland = inputs.xdg-desktop-portal-hyprland.packages.${final.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
    stable = import inputs.nixpkgs-stable {
      system = final.stdenv.hostPlatform.system;
      config.allowUnfree = true;
    };
    vesktop = prev.vesktop.override {
      withSystemVencord = false;
      withMiddleClickScroll = true;
    };
    discord = prev.discord.override {
      withVencord = true;
      withOpenASAR = true;
      enableAutoscroll = true;
    };
    deskflow = prev.deskflow.overrideAttrs (_old: {
      version = "1.26.0";
      src = prev.fetchFromGitHub {
        owner = "deskflow";
        repo = "deskflow";
        tag = "v1.26.0";
        hash = "sha256-XcSG47Ysjn+wrJH5DC/XXGXcneXcW7xIhAn6sguuv+s=";
      };
    });
  };
}
