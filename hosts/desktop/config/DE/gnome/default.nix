{ config, lib, pkgs, ... }:

{
  # GNOME specific settings for nixos-desktop
  dconf.settings = {
    "org/gnome/desktop/input-sources".sources = [
      (lib.hm.gvariant.mkTuple [ "xkb" "us" ]) # Layout is fixed to 'us' as per home.nix
    ];
  };
}
