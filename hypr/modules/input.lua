-- ===========================================================================
-- modules/input.lua — Keyboard, mouse, touchpad, cursor and gestures
--
-- Required by hyprland.lua. hl.config() sets options by section; Lua names
-- use "_" where Hyprland's option list uses "-" (tap-to-click → tap_to_click).
-- Unset options keep Hyprland's defaults.
-- ===========================================================================

-- cursor — pointer behaviour. Other options in this section:
--   warp_on_change_workspace  0 disable (default), 1 enable, 2 force: move the
--                             cursor to the last focused window on workspace change
--   warp_on_monitor_change    same values, -1 = follow the option above
--   no_warps                  never warp the cursor
--   inactive_timeout          seconds before hiding an idle cursor (0 = never)
--   hide_on_key_press         hide the cursor while typing
--   no_hardware_cursors       0 off, 1 on, 2 auto (default)
--   enable_hyprcursor, sync_gsettings_theme, zoom_factor, default_monitor
hl.config({
    cursor = {
        warp_on_change_workspace = false,   -- Don't jump cursor when switching workspaces (was jumping when switching to Steam WS)
    },
})

-- input — keyboard and mouse. Other options in this section:
--   kb_model, kb_variant, kb_rules, kb_file   more XKB keymap settings
--   repeat_rate / repeat_delay  key repeat (default 25/s after 600 ms)
--   sensitivity                 -1.0..1.0 pointer speed (0 = unchanged)
--   accel_profile               adaptive, flat or custom
--   follow_mouse                0 disabled, 1 follow (default; focus follows
--                               the cursor), 2 detached, 3 separate
--   natural_scroll, scroll_factor, scroll_method, left_handed
-- touchpad — other options: middle_button_emulation, clickfinger_behavior,
--   tap_button_map (lrm/lmr), drag_3fg, flip_x, flip_y
hl.config({
    input = {
        kb_layout          = "us",
        kb_options         = "caps:escape",   -- Caps Lock → Escape (very useful in Neovim)
        numlock_by_default = true,

        -- Mouse — focus follows the cursor, default speed, no acceleration
        follow_mouse  = 1,
        sensitivity   = 0,
        accel_profile = "flat",

        touchpad = {
            natural_scroll       = true,    -- Scroll direction like macOS
            tap_to_click         = true,    -- Tap = left click
            tap_and_drag         = true,    -- Tap + hold = drag
            drag_lock            = false,
            disable_while_typing = true,
            scroll_factor        = 0.8,     -- Slightly slower scroll speed
        },
    },
})

-- Touchpad gesture — three-finger horizontal swipe switches workspaces.
-- hl.gesture() fields:
--   fingers    number of fingers
--   direction  swipe, left, right, up, down, horizontal, vertical, pinch,
--              pinchin, pinchout
--   action     workspace, special, move, resize, close, float, fullscreen,
--              cursor_zoom, scroll_move, unset, or a Lua function / table of
--              start/update/end callbacks
--   mods, scale, disable_inhibit, workspace_name, mode, zoom_level  optional
-- Swipe tuning lives in the gestures section (workspace_swipe_distance,
-- workspace_swipe_invert, workspace_swipe_create_new, ...).
hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})
