#!/usr/bin/env bash
# ===========================================================================
# screenshot.sh — take a screenshot, save and copy it, edit on demand
#
# Usage: screenshot.sh [area|fullscreen|smart] [save|copy]
#   area        freehand region via slurp (default)
#   fullscreen  the focused monitor
#   smart       slurp -r with the focused workspace's monitor and windows as
#               targets; a drag still selects freely, a click selects the
#               window or monitor under the cursor
#   save        (default) write ~/Pictures/Screenshots/screenshot-<time>.png,
#               copy it, and show a notification whose action opens satty
#   copy        clipboard only, no file, no notification
# Bound to Print and SUPER+Print/Z/X/CTRL+Z in modules/keybinds.lua.
# Running it while slurp is open cancels the selection.
# Based on omarchy's omarchy-cmd-screenshot (basecamp/omarchy).
#
# Tools: hyprctl (monitor and window geometry), slurp (selection),
# hyprpicker -r -z (freezes the screen during selection: -r renders
# inactive displays, -z turns off the zoom lens), grim -g (capture a
# region), wl-copy, notify-send -A (action button), satty (editor).
# ===========================================================================

set -euo pipefail

pkill slurp && exit 0

SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
MODE="${1:-area}"
PROCESSING="${2:-save}"

mkdir -p "$SCREENSHOT_DIR"

# jq helper: monitor geometry in logical px as "x,y WxH"; width and height
# swap for rotated monitors (transform 1 or 3)
JQ_MONITOR_GEO='
  def format_geo:
    .x as $x | .y as $y |
    (.width / .scale | floor) as $w |
    (.height / .scale | floor) as $h |
    .transform as $t |
    if $t == 1 or $t == 3 then
      "\($x),\($y) \($h)x\($w)"
    else
      "\($x),\($y) \($w)x\($h)"
    end;
'

get_rectangles() {
  local active_workspace
  active_workspace=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .activeWorkspace.id')
  hyprctl monitors -j | jq -r --arg ws "$active_workspace" "${JQ_MONITOR_GEO} .[] | select(.activeWorkspace.id == (\$ws | tonumber)) | format_geo"
  hyprctl clients -j | jq -r --arg ws "$active_workspace" '.[] | select(.workspace.id == ($ws | tonumber)) | "\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"'
}

# hyprpicker stays running until the script exits, so grim captures the
# frozen frame instead of content that changed during selection.
cleanup_freeze() {
  [[ -n "${PID:-}" ]] && kill "$PID" 2>/dev/null
}
trap cleanup_freeze EXIT

case "$MODE" in
  area)
    hyprpicker -r -z >/dev/null 2>&1 &
    PID=$!
    sleep .1
    SELECTION=$(slurp 2>/dev/null) || exit 0
    ;;
  fullscreen)
    SELECTION=$(hyprctl monitors -j | jq -r "${JQ_MONITOR_GEO} .[] | select(.focused == true) | format_geo")
    ;;
  smart)
    RECTS=$(get_rectangles)
    hyprpicker -r -z >/dev/null 2>&1 &
    PID=$!
    sleep .1
    SELECTION=$(echo "$RECTS" | slurp -r 2>/dev/null) || exit 0

    # A click gives a tiny selection (< 20 px²): use the first window or
    # monitor rectangle that contains the click point instead
    if [[ $SELECTION =~ ^([0-9]+),([0-9]+)\ ([0-9]+)x([0-9]+)$ ]]; then
      if (( "${BASH_REMATCH[3]}" * "${BASH_REMATCH[4]}" < 20 )); then
        click_x="${BASH_REMATCH[1]}"
        click_y="${BASH_REMATCH[2]}"
        while IFS= read -r rect; do
          if [[ $rect =~ ^([0-9]+),([0-9]+)\ ([0-9]+)x([0-9]+) ]]; then
            rect_x="${BASH_REMATCH[1]}"
            rect_y="${BASH_REMATCH[2]}"
            rect_width="${BASH_REMATCH[3]}"
            rect_height="${BASH_REMATCH[4]}"
            if (( click_x >= rect_x && click_x < rect_x + rect_width && click_y >= rect_y && click_y < rect_y + rect_height )); then
              SELECTION="${rect_x},${rect_y} ${rect_width}x${rect_height}"
              break
            fi
          fi
        done <<<"$RECTS"
      fi
    fi
    ;;
  *)
    echo "Usage: screenshot.sh [area|fullscreen|smart] [save|copy]"
    exit 1
    ;;
esac

[[ -z "${SELECTION:-}" ]] && exit 0

case "$PROCESSING" in
  save)
    FILEPATH="$SCREENSHOT_DIR/screenshot-$(date +'%Y-%m-%d_%H-%M-%S').png"
    grim -g "$SELECTION" "$FILEPATH" || exit 1
    wl-copy <"$FILEPATH"
    (
      ACTION=$(notify-send "Screenshot saved to clipboard and file" "Click to edit" -t 10000 -i "$FILEPATH" -A "default=edit")
      if [[ $ACTION == "default" ]]; then
        satty --filename "$FILEPATH" \
          --output-filename "$FILEPATH" \
          --actions-on-enter save-to-clipboard \
          --save-after-copy \
          --copy-command wl-copy
      fi
    ) >/dev/null 2>&1 &
    ;;
  copy)
    grim -g "$SELECTION" - | wl-copy
    ;;
  *)
    echo "Usage: screenshot.sh [area|fullscreen|smart] [save|copy]"
    exit 1
    ;;
esac
