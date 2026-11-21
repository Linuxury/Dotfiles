#!/usr/bin/env bash
# ===========================================================================
# waybar/scripts/volume.sh — waybar custom module: default sink volume with an
# icon per range
#
# Reads wpctl get-volume @DEFAULT_AUDIO_SINK@. Prints {"text": "<icon> <pct>",
# "tooltip": "Volume: <pct>%", "percentage": <pct>} (return-type "json").
# Icon by range: muted | 0% | 1-39% | 40-59% | 60-99% | 100% and above.
# Wired in config.jsonc as custom/volume (interval 2; click toggles mute, scroll
# raises/lowers 5% with wpctl).
# ===========================================================================

vol_raw=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
muted=$(echo "$vol_raw" | grep -c MUTED)
pct=$(echo "$vol_raw" | awk '{printf "%d", $2 * 100}')

if [ "$muted" -gt 0 ]; then
    icon="󰝟"   # volume_mute
elif [ "$pct" -eq 0 ]; then
    icon="󰖁"   # volume_off
elif [ "$pct" -le 39 ]; then
    icon="󰕿"   # volume_low
elif [ "$pct" -le 59 ]; then
    icon="󰖀"   # volume_medium
elif [ "$pct" -le 99 ]; then
    icon="󰕾"   # volume_high
else
    icon="󰝝"   # volume_plus (100%)
fi

echo "{\"text\":\"${icon} ${pct}\",\"tooltip\":\"Volume: ${pct}%\",\"percentage\":${pct}}"
