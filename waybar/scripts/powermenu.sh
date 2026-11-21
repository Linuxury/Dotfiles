#!/usr/bin/env bash
# ===========================================================================
# waybar/scripts/powermenu.sh — power menu in a wofi dmenu
#
# Lists Lock, Log Out, Restart, Shut Down, then runs the chosen action. The
# custom/power button in config.jsonc runs ~/.config/hypr/scripts/powermenu.sh
# (hypr/scripts/), not this copy. Actions:
#   Lock       hyprlock
#   Log Out    uwsm stop (ends the uwsm-managed session)
#   Restart    systemctl reboot
#   Shut Down  systemctl poweroff
# wofi flags: --dmenu (read choices from stdin), --normal-window (ordinary window,
# not layer-shell), --class (window class name, for window rules), --width 220 (px),
# --no-actions (no multi-action entries), --insensitive (case-insensitive search),
# --style (CSS file: ~/.config/wofi/powermenu-style.css).
# ===========================================================================

LOCK="  Lock"
LOGOUT="  Log Out"
RESTART="  Restart"
SHUTDOWN="  Shut Down"

CHOICE=$(printf '%s\n' "$LOCK" "$LOGOUT" "$RESTART" "$SHUTDOWN" \
    | wofi --dmenu \
           --normal-window \
           --class powermenu-small \
           --width 220 \
           --no-actions \
           --insensitive \
           --style ~/.config/wofi/powermenu-style.css)

case "$CHOICE" in
    "$LOCK")     hyprlock ;;
    "$LOGOUT")   uwsm stop ;;
    "$RESTART")  systemctl reboot ;;
    "$SHUTDOWN") systemctl poweroff ;;
esac
