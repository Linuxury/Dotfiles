-- ===========================================================================
-- modules/keybinds.lua — All keyboard and mouse bindings
--
-- Required by hyprland.lua. Shell-specific binds go in shell-active.lua and
-- launcher binds in components/launcher.lua (see hyprland.lua).
--
-- hl.bind(keys, action [, opts])
--   keys    "MOD + MOD + KEY": modifiers SUPER, SHIFT, CTRL, ALT; keys are
--           XKB names (Return, period, XF86AudioMute, ...) or mouse:272
--           (left), mouse:273 (right), mouse_up / mouse_down (wheel)
--   action  an hl.dsp.* dispatcher, or a Lua function to call
--   opts    table of booleans unless noted:
--     locked          also works while the screen is locked
--     repeating       repeats while the key is held
--     mouse           mouse-drag bind (with window.drag / window.resize)
--     release         fires on key release
--     long_press      fires after the key is held
--     non_consuming   the key event is also passed to the focused window
--     transparent, ignore_mods, catchall, click, drag, dont_inhibit,
--     auto_consuming, submap_universal
--     description / desc  text shown in `hyprctl binds`
-- ===========================================================================

local mod = "SUPER"

-- ── Core apps ─────────────────────────────────────────────────────────────────
-- Launcher (Noctalia), terminal, file manager, floating quick terminal.
hl.bind(mod .. " + Space",         hl.dsp.exec_cmd("noctalia msg panel-toggle launcher"))
hl.bind(mod .. " + Return",        hl.dsp.exec_cmd("kitty"))
hl.bind(mod .. " + E",             hl.dsp.exec_cmd("nautilus"))
hl.bind(mod .. " + SHIFT + Return",hl.dsp.exec_cmd("kitty --class floating-term"))

-- ── Scrolling layout ──────────────────────────────────────────────────────────
-- hl.dsp.layout("<msg>") sends a message to the active layout. Scrolling
-- layout messages used here: colresize +conf/-conf (step through
-- scrolling.explicit_column_widths), move +col/-col, swapcol l/r.
hl.bind(mod .. " + period",        hl.dsp.layout("colresize +conf"))   -- Cycle column width wider
hl.bind(mod .. " + comma",         hl.dsp.layout("colresize -conf"))   -- Cycle column width narrower
hl.bind(mod .. " + CTRL + right",  hl.dsp.layout("move +col"))         -- Scroll layout right
hl.bind(mod .. " + CTRL + left",   hl.dsp.layout("move -col"))         -- Scroll layout left
hl.bind(mod .. " + SHIFT + comma", hl.dsp.layout("swapcol l"))         -- Swap column left
hl.bind(mod .. " + SHIFT + period",hl.dsp.layout("swapcol r"))         -- Swap column right

-- ── Layout switching ──────────────────────────────────────────────────────────
-- SUPER+backslash cycles general.layout: scrolling → dwindle → master
-- (SHIFT reverses). hl.config() changes it live; workspaces without a layout
-- in their workspace rule follow it at once. A desktop notification shows
-- the new layout; its x-canonical-private-synchronous hint makes each one
-- replace the previous instead of stacking.
local _LAYOUTS = {
    { name = "scrolling", label = "Scrolling", icon = "⇄"  },  -- horizontal arrow  — columns you scroll through
    { name = "dwindle",   label = "Dwindle",   icon = "󰕰"  },  -- view_grid_outline  — binary space partitioning
    { name = "master",    label = "Master",    icon = "󰕲"  },  -- view_dashboard_variant — master pane + stack
}
local _layout_i = 1   -- starts at scrolling (matches general.layout default)

local function _cycle_layout(delta)
    _layout_i = ((_layout_i - 1 + delta) % #_LAYOUTS) + 1
    local l = _LAYOUTS[_layout_i]
    hl.config({ general = { layout = l.name } })
    hl.exec_cmd("notify-send -t 1500 -a 'Hyprland' -h 'string:x-canonical-private-synchronous:layout-cycle' '" .. l.icon .. "  Layout Changed' 'Switched to " .. l.label .. "'")
end

hl.bind(mod .. " + backslash",         function() _cycle_layout(1)  end)   -- forward
hl.bind(mod .. " + SHIFT + backslash", function() _cycle_layout(-1) end)   -- backward

-- ── Window management ─────────────────────────────────────────────────────────
hl.bind(mod .. " + Q",             hl.dsp.window.close())
hl.bind(mod .. " + F",             hl.dsp.window.fullscreen())
hl.bind(mod .. " + SHIFT + F",     hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + P",             hl.dsp.window.pseudo())             -- Dwindle pseudotile toggle

-- Move focus — arrow keys or H/J/K/L
hl.bind(mod .. " + left",  hl.dsp.focus({ direction = "left"  }))
hl.bind(mod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mod .. " + up",    hl.dsp.focus({ direction = "up"    }))
hl.bind(mod .. " + down",  hl.dsp.focus({ direction = "down"  }))
hl.bind(mod .. " + H",     hl.dsp.focus({ direction = "left"  }))
hl.bind(mod .. " + L",     hl.dsp.focus({ direction = "right" }))
hl.bind(mod .. " + K",     hl.dsp.focus({ direction = "up"    }))
hl.bind(mod .. " + J",     hl.dsp.focus({ direction = "down"  }))

-- Move windows — arrow keys or H/J/K/L
hl.bind(mod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "left"  }))
hl.bind(mod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "up"    }))
hl.bind(mod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "down"  }))
hl.bind(mod .. " + SHIFT + H",     hl.dsp.window.move({ direction = "left"  }))
hl.bind(mod .. " + SHIFT + L",     hl.dsp.window.move({ direction = "right" }))
hl.bind(mod .. " + SHIFT + K",     hl.dsp.window.move({ direction = "up"    }))
hl.bind(mod .. " + SHIFT + J",     hl.dsp.window.move({ direction = "down"  }))

-- Resize the focused window by 40 px steps
hl.bind(mod .. " + ALT + left",  hl.dsp.window.resize({ x = -40, y = 0   }))
hl.bind(mod .. " + ALT + right", hl.dsp.window.resize({ x =  40, y = 0   }))
hl.bind(mod .. " + ALT + up",    hl.dsp.window.resize({ x = 0,   y = -40 }))
hl.bind(mod .. " + ALT + down",  hl.dsp.window.resize({ x = 0,   y =  40 }))
hl.bind(mod .. " + ALT + H",     hl.dsp.window.resize({ x = -40, y = 0   }))
hl.bind(mod .. " + ALT + L",     hl.dsp.window.resize({ x =  40, y = 0   }))
hl.bind(mod .. " + ALT + K",     hl.dsp.window.resize({ x = 0,   y = -40 }))
hl.bind(mod .. " + ALT + J",     hl.dsp.window.resize({ x = 0,   y =  40 }))

-- Move/resize with the mouse while SUPER is held
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })   -- SUPER + LMB = move
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })   -- SUPER + RMB = resize

-- ── Workspaces ────────────────────────────────────────────────────────────────
-- SUPER+N goes to workspace N, SUPER+SHIFT+N moves the window there (0 = 10).
for i = 1, 9 do
    hl.bind(mod .. " + " .. i,              hl.dsp.focus({ workspace = i }))
    hl.bind(mod .. " + SHIFT + " .. i,      hl.dsp.window.move({ workspace = i }))
end
hl.bind(mod .. " + 0",          hl.dsp.focus({ workspace = 10 }))
hl.bind(mod .. " + SHIFT + 0",  hl.dsp.window.move({ workspace = 10 }))

-- SUPER + mouse wheel: next/previous existing workspace ("e+1" / "e-1")
hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Special workspace "scratch": SUPER+S shows/hides it, SUPER+SHIFT+S moves
-- the focused window into it
hl.bind(mod .. " + S",         hl.dsp.workspace.toggle_special("scratch"))
hl.bind(mod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:scratch" }))

-- ── Screenshots ───────────────────────────────────────────────────────────────
-- scripts/screenshot.sh <area|fullscreen|smart> <save|copy>
hl.bind("Print",                   hl.dsp.exec_cmd("~/.config/hypr/scripts/screenshot.sh area save"))        -- Region → save + copy, edit on demand
hl.bind(mod .. " + Print",         hl.dsp.exec_cmd("~/.config/hypr/scripts/screenshot.sh fullscreen save"))  -- Full screen → save + copy, edit on demand
hl.bind(mod .. " + Z",             hl.dsp.exec_cmd("~/.config/hypr/scripts/screenshot.sh area save"))        -- Region (alt key)
hl.bind(mod .. " + X",             hl.dsp.exec_cmd("~/.config/hypr/scripts/screenshot.sh fullscreen save"))  -- Full screen (alt key)
hl.bind(mod .. " + CTRL + Z",      hl.dsp.exec_cmd("~/.config/hypr/scripts/screenshot.sh smart save"))       -- Smart select (window/monitor snap)
hl.bind("SHIFT + Print",           hl.dsp.exec_cmd("~/.config/hypr/scripts/screenshot.sh area copy"))        -- Region → clipboard only
hl.bind(mod .. " + SHIFT + Print", hl.dsp.exec_cmd("~/.config/hypr/scripts/screenshot.sh fullscreen copy"))  -- Full screen → clipboard only

-- ── Screen recording ─────────────────────────────────────────────────────────
-- scripts/screen-record.sh <area|fullscreen>; the same keys again stop it
hl.bind(mod .. " + ALT + R",         hl.dsp.exec_cmd("~/.config/hypr/scripts/screen-record.sh area"))
hl.bind(mod .. " + ALT + SHIFT + R", hl.dsp.exec_cmd("~/.config/hypr/scripts/screen-record.sh fullscreen"))

-- ── Screen lock ───────────────────────────────────────────────────────────────
hl.bind(mod .. " + Escape",        hl.dsp.exec_cmd("noctalia msg session lock"))
-- Suspend now; -i (--ignore-inhibitors) ignores apps blocking sleep, such
-- as a browser playing video
hl.bind(mod .. " + CTRL + Escape", hl.dsp.exec_cmd("systemctl suspend -i"))

-- ── Audio — volume with OSD ────────────────────────────────────────────────
-- Volume goes through Noctalia IPC (`noctalia msg ...`) so its OSD shows.
-- All work while locked; volume keys repeat while held.
-- Output (speaker)
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("noctalia msg volume-up"),          { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("noctalia msg volume-down"),        { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("noctalia msg volume-mute"),        { locked = true })
-- Input (mic) — SHIFT + volume keys
hl.bind("SHIFT + XF86AudioRaiseVolume", hl.dsp.exec_cmd("noctalia msg mic-volume-up"),   { locked = true, repeating = true })
hl.bind("SHIFT + XF86AudioLowerVolume", hl.dsp.exec_cmd("noctalia msg mic-volume-down"), { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("noctalia msg mic-mute"),  { locked = true })
-- Media keys — playerctl controls the active MPRIS player
hl.bind("XF86AudioPlay",        hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext",        hl.dsp.exec_cmd("playerctl next"),        { locked = true })
hl.bind("XF86AudioPrev",        hl.dsp.exec_cmd("playerctl previous"),    { locked = true })
-- Audio device switching — Noctalia's control-center audio panel holds both
-- the output and input pickers, so both binds open it
hl.bind(mod .. " + A",         hl.dsp.exec_cmd("noctalia msg panel-open control-center audio"))  -- Switch output
hl.bind(mod .. " + SHIFT + A", hl.dsp.exec_cmd("noctalia msg panel-open control-center audio"))  -- Switch input

-- ── Brightness ────────────────────────────────────────────────────────────────
-- brightnessctl set +5% / 5%- on the backlight; repeats while held
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl set +5%"), { repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), { repeating = true })

-- ── Exit / reload ─────────────────────────────────────────────────────────────
-- Power menu, config reload, Noctalia night light
hl.bind(mod .. " + SHIFT + E", hl.dsp.exec_cmd("~/.config/hypr/scripts/powermenu.sh"))
hl.bind(mod .. " + SHIFT + R", hl.dsp.exec_cmd("hyprctl reload"))
hl.bind(mod .. " + SHIFT + N", hl.dsp.exec_cmd("noctalia msg nightlight-toggle"))  -- Night light toggle
-- Restart Noctalia — clears stale workspace window counts left by Wine/Steam
-- helper windows
hl.bind(mod .. " + CTRL + N",  hl.dsp.exec_cmd("systemctl --user restart noctalia.service"))

-- ── Gaming ────────────────────────────────────────────────────────────────────
-- Switch to workspace 2 and back to release a pointer lock a fullscreen game
-- did not let go of
hl.bind(mod .. " + CTRL + G", hl.dsp.exec_cmd(
    "hyprctl dispatch 'hl.dsp.focus({ workspace = \"2\" })' && sleep 0.15 && hyprctl dispatch 'hl.dsp.focus({ workspace = \"previous\" })'"
))
-- steam-bpm: Steam Big Picture in gamescope; the gamescope window rule in
-- windowrules.lua sends it to workspace 2
hl.bind(mod .. " + CTRL + B", hl.dsp.exec_cmd("steam-bpm"))

