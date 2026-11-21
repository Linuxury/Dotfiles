#!/usr/bin/env bash
# ===========================================================================
# waybar/scripts/sysinfo.sh — one-line CPU / RAM / disk readout
#
# Prints {"text": "<cpu>% · <ram>% · <disk>%", "tooltip": "CPU / RAM (GiB) / Disk"}.
#   CPU   busy share between this call and the previous one: /proc/stat totals
#         are diffed against the last pair stored in CPU_CACHE (0 on the first call)
#   RAM   used/total from `free -m`
#   Disk  used share of / from `df /`
# Not referenced by config.jsonc; waybar would run it as a custom module with
# return-type "json".
# ===========================================================================

CPU_CACHE="/tmp/waybar-cpu-prev"

# CPU
read -r _ user nice system idle iowait irq softirq steal _ _ < /proc/stat
total=$((user + nice + system + idle + iowait + irq + softirq + steal))
idle_total=$((idle + iowait))

if [ -f "$CPU_CACHE" ]; then
    read -r prev_total prev_idle < "$CPU_CACHE"
    diff_total=$((total - prev_total))
    diff_idle=$((idle_total - prev_idle))
    [ "$diff_total" -gt 0 ] && cpu_pct=$(( (diff_total - diff_idle) * 100 / diff_total )) || cpu_pct=0
else
    cpu_pct=0
fi
echo "$total $idle_total" > "$CPU_CACHE"

# Memory
read -r mem_pct mem_used mem_total < <(
    free -m | awk '/Mem:/ {printf "%.0f %.1f %.1f", $3/$2*100, $3/1024, $2/1024}'
)

# Disk
disk_pct=$(df / | awk 'NR==2 {printf "%.0f", $3/$2*100}')

TEXT="󰻠 ${cpu_pct}% · ${mem_pct}% · ${disk_pct}%"
TOOLTIP="CPU: ${cpu_pct}%\nRAM: ${mem_used}/${mem_total} GiB (${mem_pct}%)\nDisk: ${disk_pct}%"

printf '{"text":"%s","tooltip":"%s"}\n' "$TEXT" "$TOOLTIP"
