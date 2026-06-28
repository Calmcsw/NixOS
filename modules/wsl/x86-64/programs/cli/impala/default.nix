{ pkgs, ... }:
{
    environment.systemPackages = with pkgs; [
        impala
    ];
}
