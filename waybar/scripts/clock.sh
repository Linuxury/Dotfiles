#!/usr/bin/env bash
# ===========================================================================
# waybar/scripts/clock.sh — waybar custom module: date and 12-hour time
#
# Wired in config.jsonc as custom/clock (return-type "json", interval 1).
# Prints {"text": "<date>   <time>", "tooltip": "<cal output>"}.
#   text     "%A, %d %b %Y" and "%-I:%M %p" from date(1); `-` after % drops the
#            leading zero (GNU date), which waybar's own clock format cannot do
#   tooltip  this month's `cal` calendar, with < and > escaped for Pango markup
# ===========================================================================

TIME=$(date +"%-I:%M %p")
DATE=$(date +"%A, %d %b %Y")
CAL=$(cal | sed 's/</\&lt;/g; s/>/\&gt;/g')

printf '{"text":"%s   %s","tooltip":"%s"}\n' \
    "$DATE" "$TIME" "$(echo "$CAL" | awk '{printf "%s\\n", $0}')"
