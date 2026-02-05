{ config, pkgs, var, ... }:
{
  imports = [
    ./DE/gnome/gnome.nix
    ./DE/kde/kde.nix
    ./DE/niri/niri.nix
  ];
}
