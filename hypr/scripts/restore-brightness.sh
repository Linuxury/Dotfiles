#!/usr/bin/env bash
# scripts/restore-brightness.sh — put the backlight back after dim-screen.sh
#
# Run by hypridle (hypridle-laptop.conf, on-resume of the dim listener).
# Does nothing when brightnessctl lists no backlight device (desktops).
#   brightnessctl -l   list devices with brightness controls
#   brightnessctl -r   restore the level saved by `-s` in dim-screen.sh

DEVICE=$(brightnessctl -l 2>/dev/null | grep -m1 "backlight")
if [ -n "$DEVICE" ]; then
    brightnessctl -r
fi
