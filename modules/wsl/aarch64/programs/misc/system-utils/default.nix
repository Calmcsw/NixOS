{ pkgs, ... }:
{
    environment.systemPackages = with pkgs; [
        bottles
        gnome-calculator
        gnome-disk-utility # Disk Partitioning and Mounting Utility
    ];
}
