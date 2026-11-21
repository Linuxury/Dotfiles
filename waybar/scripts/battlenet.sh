#!/usr/bin/env bash
# ===========================================================================
# waybar/scripts/battlenet.sh — waybar custom module: Battle.net window button
#
# Prints a JSON icon (return-type "json": text, tooltip) while a window with
# class steam_app_0 and title "Battle.net" exists, else prints nothing.
# Wired in config.jsonc as custom/battlenet:
#   exec            this script, polled every 3 s (interval)
#   exec-if         pgrep for Battle.net.exe: script runs only while it is up
#   on-click        hyprctl dispatch focuswindow class:steam_app_0 (focus)
#   on-click-right  this script with the argument `close` (closes the window)
# Usage:
#   battlenet.sh          print the module JSON
#   battlenet.sh close    close the window by class (hyprctl dispatch closewindow)
# ===========================================================================

# Window class (Proton runs Battle.net under steam_app_0) and window title to match.
CLASS="steam_app_0"
TITLE="Battle.net"

# `close` argument: close the window, print nothing
if [ "$1" = "close" ]; then
    hyprctl dispatch closewindow class:$CLASS 2>/dev/null
    exit 0
fi

# Look the window up in hyprctl clients (JSON) by class and title; WIN = its address
WIN=$(hyprctl clients -j 2>/dev/null | python3 -c "
import json, sys
for c in json.load(sys.stdin):
    if c.get('class') == '$CLASS' and c.get('title') == '$TITLE':
        print(c['address'])
        break
" 2>/dev/null)

[ -z "$WIN" ] && exit 0

# Compare with hyprctl activewindow so the tooltip says whether it already has focus
FOCUSED=$(hyprctl activewindow -j 2>/dev/null | python3 -c "import json,sys;print(json.load(sys.stdin).get('address',''))" 2>/dev/null)

if [ "$FOCUSED" = "$WIN" ]; then
    TOOLTIP="Battle.net (focused) — Right-click to close"
else
    TOOLTIP="Battle.net — Click to focus, Right-click to close"
fi

echo "{\"text\":\"󰊴\",\"tooltip\":\"$TOOLTIP\"}"
