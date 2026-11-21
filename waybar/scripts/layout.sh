#!/usr/bin/env bash
# ===========================================================================
# waybar/scripts/layout.sh — waybar custom module: Hyprland layout of the
# current workspace
#
# Wired in config.jsonc as custom/layout (return-type "json", interval 2,
# on-click runs this script with `cycle`).
# Usage:
#   layout.sh          print {"text": <icon>, "tooltip": <name>} for the
#                      workspace's tiledLayout (hyprctl activeworkspace -j)
#   layout.sh cycle    switch the workspace to the next layout:
#                      scrolling -> dwindle -> master -> scrolling
#                      (any other current layout goes to dwindle)
# ===========================================================================

active_json=$(hyprctl activeworkspace -j 2>/dev/null)
LAYOUT=$(printf '%s' "$active_json" | grep -oP '"tiledLayout":\s*"\K[^"]+')
WSID=$(printf '%s'   "$active_json" | grep -oP '"id":\K\d+'       | head -1)

case "$1" in
  cycle)
    case "$LAYOUT" in
      scrolling) NEXT=dwindle  ;;
      dwindle)   NEXT=master   ;;
      master)    NEXT=scrolling;;
      *)         NEXT=dwindle  ;;
    esac
    hyprctl keyword workspace "$WSID, layout:$NEXT" > /dev/null
    exit 0
    ;;
  *)
    case "$LAYOUT" in
      scrolling) echo '{"text":"󰕴","tooltip":"Scrolling layout"}' ;;
      dwindle)   echo '{"text":"󰕰","tooltip":"Dwindle layout"}'   ;;
      master)    echo '{"text":"󱂬","tooltip":"Master layout"}'    ;;
      *)         echo '{"text":"󰕴","tooltip":"'"$LAYOUT"'"}'      ;;
    esac
    ;;
esac
