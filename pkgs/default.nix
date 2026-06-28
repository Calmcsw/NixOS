{ host, pkgs, ... }:
{
  # these will be overlayed in nixpkgs automatically.
  # for example: environment.systemPackages = with pkgs; [pokego];
  pokego = pkgs.callPackage ./pokego.nix { };
  goxlr-utility-ui = pkgs.callPackage ./goxlr-utility-ui.nix { };
}
