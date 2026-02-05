{ pkgs, lib, var, ... }:

with lib;

let
  cfg = var.desktop;
in
mkIf (builtins.hasAttr "enableKde" cfg && cfg.enableKde) {
  imports = [
    cfg.kdeConfigPath
  ];
}
