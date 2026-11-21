#!/usr/bin/env bash
# ===========================================================================
# waybar/scripts/updates.sh — waybar custom module: pending NixOS rebuild
#
# Compares the mtime of ~/nixos-config/flake.lock with /run/current-system
# (stat -c %Y, seconds; a missing path counts as 0). A newer flake.lock means a
# rebuild is pending.
# Output (return-type "json"):
#   pending  {"text": "󰚰  rebuild", "tooltip": "...", "class": "pending"}
#   ok       {"text": "", "class": "ok"}   (empty: module shows nothing)
# Wired in config.jsonc as custom/updates, interval 3600 (hourly).
# ===========================================================================

FLAKE_DIR="$HOME/nixos-config"
LOCK_FILE="$FLAKE_DIR/flake.lock"

LOCK_TIME=$(stat -c %Y "$LOCK_FILE" 2>/dev/null || echo 0)
BUILD_TIME=$(stat -c %Y /run/current-system 2>/dev/null || echo 0)

if [ "$LOCK_TIME" -gt "$BUILD_TIME" ]; then
    printf '{"text":"󰚰  rebuild","tooltip":"flake.lock is newer than running system — run: nr","class":"pending"}\n'
else
    printf '{"text":"","class":"ok"}\n'
fi
