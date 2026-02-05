{ pkgs, lib, var, ... }:

with lib;

let
  cfg = var.desktop;
in
mkIf cfg.enableGnome {
  imports = [
    cfg.gnomeConfigPath
  ];
}
