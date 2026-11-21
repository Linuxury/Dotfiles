#!/usr/bin/env bash
# ===========================================================================
# scripts/powermenu.sh — power / session menu in wofi
#
# Bound to SUPER+SHIFT+E in modules/keybinds.lua. Each entry runs a Noctalia
# session action (`noctalia msg session <action>`):
#   Lock      lock     lock the screen
#   Logout    logout   end the session, back to the login screen
#   Suspend   suspend
#   Reboot    reboot
#   Shutdown  shutdown
#
# wofi flags used:
#   --dmenu          read entries from stdin, print the chosen one
#   --normal-window  normal window instead of a layer-shell surface, so
#                    window rules apply
#   --class          window class; windowrules.lua floats, centers and
#                    rounds class "powermenu"
#   --width          window width in px
#   --location       center (default); see wofi(7) for the others
#   --style          stylesheet; ~/.config/wofi/powermenu-style.css
#   --no-actions     no sub-actions per entry
#   --insensitive    case-insensitive search
# Other wofi flags: --prompt, --lines, --conf, --matching, --allow-images
# ===========================================================================

LOCK="󰤄  Lock"
LOGOUT="󰍃  Logout"
SUSPEND="󰒲  Suspend"
REBOOT="󰜉  Reboot"
SHUTDOWN="󰐥  Shutdown"

CHOICE=$(printf '%s\n' "$LOCK" "$LOGOUT" "$SUSPEND" "$REBOOT" "$SHUTDOWN" \
    | wofi \
        --dmenu \
        --normal-window \
        --class powermenu \
        --width  320 \
        --location center \
        --style "$HOME/.config/wofi/powermenu-style.css" \
        --no-actions \
        --insensitive)

case "$CHOICE" in
    "$LOCK")     noctalia msg session lock ;;
    "$LOGOUT")   noctalia msg session logout ;;
    "$SUSPEND")  noctalia msg session suspend ;;
    "$REBOOT")   noctalia msg session reboot ;;
    "$SHUTDOWN")  noctalia msg session shutdown ;;
esac
