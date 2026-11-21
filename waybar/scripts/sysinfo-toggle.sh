#!/usr/bin/env bash
# ===========================================================================
# waybar/scripts/sysinfo-toggle.sh — flip the sysinfo "expanded" flag
#
# Creates STATE_FILE if absent, removes it if present, then sends SIGRTMIN+8 to
# waybar. waybar re-runs a custom module whose config sets "signal": 8
# (waybar-custom: the signal number N is SIGRTMIN+N). Meant as the on-click of a
# custom/sysinfo module; config.jsonc has no such module, and sysinfo.sh does not
# read STATE_FILE.
# ===========================================================================

STATE_FILE="$HOME/.local/share/waybar-sysinfo-expanded"

if [ -f "$STATE_FILE" ]; then
    rm "$STATE_FILE"
else
    touch "$STATE_FILE"
fi

# Re-run modules with "signal": 8 now
pkill -SIGRTMIN+8 waybar
