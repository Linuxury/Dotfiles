#!/usr/bin/env bash
# ===========================================================================
# compositor-dpms.sh — turn displays on or off through Noctalia
#
# Usage: compositor-dpms.sh on|off
# Runs `noctalia msg dpms-on` / `dpms-off`, so it works under any compositor
# Noctalia runs on (Hyprland or Umbriel). Called by the hypridle profiles.
# ===========================================================================
set -euo pipefail

noctalia msg "dpms-$1"
