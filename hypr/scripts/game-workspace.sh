#!/usr/bin/env bash
# game-workspace.sh — move game windows to workspace 2 once they settle
#
# Started once from modules/autostart.lua (hyprland.start). Window rules are
# checked when a window opens, before launchers such as Steam or Prism make
# it fullscreen, so they cannot place these windows reliably. This script
# reads Hyprland's event socket (socket2, via socat) and handles each event
# in the background:
#
#   openwindow>>ADDRESS,WORKSPACE,CLASS,TITLE
#     After 1 s, moves the window if it is a known game:
#       xdgTag "proton-game"              Steam/Proton native Wayland games
#       class starting with "Minecraft"   Minecraft via Prism Launcher
#       class "steam_app_0" with a title  Battle.net games (its tray icon
#                                         has an empty title)
#
#   fullscreen>>1 / fullscreen>>0  (entered / left fullscreen)
#     On 1, after 0.3 s, moves the active window unless its class is in the
#     is_non_game list (browsers, terminals, media players, image viewers,
#     the Steam client). The ADDRESS,STATE branch below handles an event
#     payload with a window address and state (1 maximized, 2 fullscreen).
#
# Windows already on workspace 2 are left alone. Moves use the Lua
# dispatcher form: in Lua-config mode `hyprctl dispatch ARGS` runs
# `return hl.dispatch(ARGS)`, so ARGS must be a Lua hl.dsp.* expression.
# Window details come from `hyprctl clients -j` / `activewindow -j`.

SOCKET="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

is_game() {
    local addr="$1"
    python3 -c "
import json, subprocess
data = json.loads(subprocess.check_output(['hyprctl', 'clients', '-j']))
for w in data:
    if w['address'] == '0x$addr':
        xdg_tag = w.get('xdgTag', '')
        cls     = w.get('class', '')
        title   = w.get('title', '')
        if xdg_tag == 'proton-game':
            print('match')
        elif cls.startswith('Minecraft'):
            print('match')
        elif cls == 'steam_app_0' and title:
            print('match')
        break
" 2>/dev/null
}

is_non_game() {
    local addr="$1"
    python3 -c "
import json, subprocess
data = json.loads(subprocess.check_output(['hyprctl', 'clients', '-j']))
NON_GAME = {
    # Browsers
    'firefox', 'firefox-esr', 'firefox-nightly',
    'zen-beta', 'zen-alpha', 'zen',
    'chromium', 'chromium-browser', 'google-chrome', 'google-chrome-stable',
    'brave-browser', 'microsoft-edge', 'opera', 'vivaldi-stable',
    # Terminals
    'kitty', 'ghostty', 'alacritty', 'wezterm', 'org.gnome.terminal',
    # Video / media players
    'mpv', 'vlc', 'totem', 'showtime',
    'com.github.neithern.g4music',
    'io.github.celluloid_player.celluloid',
    # Image viewers
    'org.gnome.loupe', 'eog',
    # Steam client — video playback triggers fullscreen on the client window;
    # game windows use class steam_app_XXXXX and are handled by openwindow/is_game.
    'steam',
}
for w in data:
    if w['address'] == '0x$addr':
        if w.get('class', '').lower() in NON_GAME:
            print('excluded')
        break
" 2>/dev/null
}

move_to_ws2() {
    local addr="$1"
    local ws
    ws=$(python3 -c "
import json, subprocess
data = json.loads(subprocess.check_output(['hyprctl', 'clients', '-j']))
for w in data:
    if w['address'] == '0x$addr':
        print(w.get('workspace', {}).get('id', ''))
        break
" 2>/dev/null)
    [[ "$ws" == "2" ]] && return
    hyprctl dispatch "hl.dsp.window.move({workspace=2,follow=false,window='address:0x$addr'})" 2>/dev/null
}

handle() {
    local event="$1"

    if [[ "$event" == openwindow* ]]; then
        # openwindow>>address,workspacename,class,title
        local addr="${event#openwindow>>}"
        addr="${addr%%,*}"
        sleep 1
        if [[ "$(is_game "$addr")" == "match" ]]; then
            move_to_ws2 "$addr"
        fi

    elif [[ "$event" == fullscreen* ]]; then
        local payload="${event#fullscreen>>}"
        local addr state

        if [[ "$payload" == *","* ]]; then
            # Payload with an address: ADDRESS,INTERNALSTATE[,CLIENTSTATE]
            addr="${payload%%,*}"
            addr="${addr#0x}"   # normalize — strip 0x if present in event
            local rest="${payload#*,}"
            state="${rest%%,*}"
            # Act on fullscreen (2) and maximized (1): some games' windowed
            # fullscreen modes request maximize instead. 0 (none) is ignored.
            # Still filtered through is_non_game() below.
            [[ "$state" == "2" || "$state" == "1" ]] || return
        else
            # Plain payload: 1 = entered fullscreen, 0 = left; use the
            # active window's address
            [[ "$payload" == "1" ]] || return
            addr=$(hyprctl activewindow -j 2>/dev/null \
                   | python3 -c "import json,sys; print(json.load(sys.stdin).get('address','').lstrip('0x'))" 2>/dev/null)
            [[ -z "$addr" ]] && return
        fi

        sleep 0.3
        [[ "$(is_non_game "$addr")" == "excluded" ]] && return
        move_to_ws2 "$addr"
    fi
}

socat -U - "UNIX-CONNECT:$SOCKET" | while IFS= read -r line; do
    handle "$line" &
done
