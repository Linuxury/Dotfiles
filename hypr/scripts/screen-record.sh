#!/usr/bin/env bash
# ===========================================================================
# screen-record.sh — start or stop a screen recording with wf-recorder
#
# Usage: screen-record.sh [area|fullscreen]
#   area        select a region with slurp (default)
#   fullscreen  record the whole output
# Bound to SUPER+ALT+R (area) and SUPER+ALT+SHIFT+R (fullscreen) in
# modules/keybinds.lua. Running it while a recording is active stops that
# recording (SIGINT, which makes wf-recorder finish the file).
# Saves to ~/Videos/Screen Recordings/recording-YYYYMMDD-HHMMSS.mp4; the
# recorder PID is kept in /tmp/screen-record.pid.
#
# wf-recorder flags used: -g "x,y WxH" region, -f output file (container
# from the extension). Others: -a audio, -o output name, -c codec,
# -r framerate, -d device (GPU encoding), -F ffmpeg filter.
# ===========================================================================

set -euo pipefail

RECORD_DIR="$HOME/Videos/Screen Recordings"
PID_FILE="/tmp/screen-record.pid"
MODE="${1:-area}"

# A live PID in the PID file means a recording is running: stop it
if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if kill -0 "$PID" 2>/dev/null; then
        kill -INT "$PID"
        rm -f "$PID_FILE"
        notify-send -t 3000 "  Recording Saved" "$(f=$(ls -t "$RECORD_DIR"/recording-*.mp4 2>/dev/null | head -1); basename "${f:-recording.mp4}")"
        exit 0
    fi
    rm -f "$PID_FILE"
fi

mkdir -p "$RECORD_DIR"
FILENAME="$RECORD_DIR/recording-$(date +%Y%m%d-%H%M%S).mp4"

# Start wf-recorder in the background
case "$MODE" in
    area)
        GEOMETRY=$(slurp 2>/dev/null) || exit 1
        wf-recorder -g "$GEOMETRY" -f "$FILENAME" &
        ;;
    fullscreen)
        wf-recorder -f "$FILENAME" &
        ;;
    *)
        echo "Usage: screen-record.sh [area|fullscreen]"
        exit 1
        ;;
esac

PID=$!
echo "$PID" > "$PID_FILE"
notify-send -t 3000 "  Recording Started" "Press keybind again to stop"
