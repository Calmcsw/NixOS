{ pkgs, ... }:
{
    environment.systemPackages = with pkgs; [
       libreoffice-still
       collabora-online
    ];
}
