#!/usr/bin/env sh
# ===========================================================================
# host-overrides.sh — per-host Hyprland settings applied at login
#
# Started once from modules/autostart.lua (hyprland.start). Picks rules by
# $HOSTNAME for settings that depend on the host's display and so do not
# belong in the shared config. Hosts not listed get no overrides.
# ===========================================================================

case "$HOSTNAME" in
    Ryzen5900x)
        # OLED display: kitty at 0.9 focused / 0.8 unfocused opacity and no
        # blur behind it, so text stays readable on bright wallpapers
        hyprctl keyword windowrule "match:class kitty, opacity 0.9 override 0.8 override"
        hyprctl keyword windowrule "match:class kitty, no_blur on"
        ;;
    # ThinkPad: uses the shared kitty rule in windowrules.lua (0.75 / 0.6)
esac
