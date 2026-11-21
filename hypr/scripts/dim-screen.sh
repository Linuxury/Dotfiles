#!/usr/bin/env bash
# scripts/dim-screen.sh — dim the backlight when idle
#
# Run by hypridle (hypridle-laptop.conf, on-timeout of the dim listener).
# Does nothing when brightnessctl lists no backlight device (desktops).
#   brightnessctl -s       save the current level for `-r` (restore-brightness.sh)
#   set VALUE              raw value (500), percent (50%), or delta (+10, 10%-)

DEVICE=$(brightnessctl -l 2>/dev/null | grep -m1 "backlight")
if [ -n "$DEVICE" ]; then
    brightnessctl -s set 30
fi
