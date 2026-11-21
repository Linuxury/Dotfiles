#!/usr/bin/env bash
# ===========================================================================
# waybar/scripts/media-scroll.sh — waybar custom module: scrolling "artist —
# title" ticker for the active MPRIS player
#
# Wired in config.jsonc as custom/media-scroll (return-type "json", interval 1,
# exec-if: playerctl reports Playing or Paused). Each call prints
# {"text": ..., "class": "playing"|"paused"}; the class is a CSS hook in style.css.
#   text <= DISPLAY_LEN chars   shown whole (prefixed while paused), no scrolling
#   longer text                 a DISPLAY_LEN window slides STEP chars per call over
#                               the text + PAD spaces + the text, so it loops
# The position and a track key (first 40 chars) are kept in STATE; a new track
# restarts the scroll. The text is empty when the player is stopped or has no
# artist and title. DISPLAY_LEN = visible characters, STEP = characters advanced
# per call, PAD = spaces between the end of the text and its restart. Text is
# escaped for Pango (&, <, >) and JSON (").
# ===========================================================================

DISPLAY_LEN=40
STEP=1        # characters to advance per second
PAD=8         # gap between end and restart of the loop

STATE="/tmp/waybar-mpris-scroll"

STATUS=$(playerctl status 2>/dev/null) || STATUS=""

if [[ -z "$STATUS" || "$STATUS" == "Stopped" ]]; then
    echo '{"text":""}'
    rm -f "$STATE"
    exit 0
fi

ARTIST=$(playerctl metadata artist 2>/dev/null)
TITLE=$(playerctl metadata title 2>/dev/null)

if [[ -z "$ARTIST" && -z "$TITLE" ]]; then
    echo '{"text":""}'
    exit 0
fi

[[ -n "$ARTIST" && -n "$TITLE" ]] && FULL="${ARTIST} — ${TITLE}" || FULL="${ARTIST}${TITLE}"

N=$(printf '%s' "$FULL" | awk '{print length}')

# Short enough: print it whole
if (( N <= DISPLAY_LEN )); then
    [[ "$STATUS" == "Paused" ]] && p="  " || p=""
    e="${FULL//&/&amp;}"; e="${e//</&lt;}"; e="${e//>/&gt;}"; e="${e//\"/\\\"}"
    echo "{\"text\":\"${p}${e}\",\"class\":\"${STATUS,,}\"}"
    rm -f "$STATE"
    exit 0
fi

# Track key: first 40 characters of the text
TRACK_ID=$(printf '%s' "$FULL" | awk '{print substr($0,1,40)}')

# Load the saved position; start over when the key differs
POS=0
if [[ -f "$STATE" ]]; then
    IFS=: read -r saved_pos saved_id < "$STATE"
    [[ "$saved_id" == "$TRACK_ID" ]] && POS=$saved_pos
fi

# Window = DISPLAY_LEN characters of text + PAD + text, starting at POS
PADDED="${FULL}$(printf '%*s' "$PAD" '')${FULL}"
WINDOW=$(printf '%s' "$PADDED" | awk -v p=$((POS+1)) -v l="$DISPLAY_LEN" '{print substr($0,p,l)}')

# Advance by STEP, wrap at text length + PAD
NEXT_POS=$(( (POS + STEP) % (N + PAD) ))
printf '%s:%s\n' "$NEXT_POS" "$TRACK_ID" > "$STATE"

[[ "$STATUS" == "Paused" ]] && p="  " || p=""
w="${WINDOW//&/&amp;}"; w="${w//</&lt;}"; w="${w//>/&gt;}"
w="${w//\\/\\\\}"; w="${w//\"/\\\"}"

echo "{\"text\":\"${p}${w}\",\"class\":\"${STATUS,,}\"}"
