-- ===========================================================================
-- modules/windowrules.lua — Per-app window behavior
--
-- Required by hyprland.lua. hl.window_rule(table) adds one rule. Fields:
--   name     optional identifier, shown in errors and debug output
--   enabled  optional, false keeps the rule but turns it off
--   match    which windows it applies to: class, title, initial_class,
--            initial_title, tag, xdg_tag, content, workspace, group, modal,
--            focus, float, fullscreen, pin, xwayland,
--            fullscreen_state_internal, fullscreen_state_client.
--            Strings are RE2 regexes matched against the WHOLE value
--            ("kitty" matches only "kitty"; use "foo.*" for a prefix);
--            a "negative:" prefix inverts the match.
--   effects  every other field, e.g.
--            placement   float, tile, fullscreen, maximize, center, pseudo,
--                        pin, move, size, min_size, max_size, monitor,
--                        workspace ("N silent" = send there without
--                        switching), group, no_initial_focus
--            look        opacity, rounding, rounding_power, border_size,
--                        border_color, no_blur, no_shadow, no_dim,
--                        dim_around, no_anim, animation, opaque, xray
--            behaviour   idle_inhibit, keep_aspect_ratio, no_focus,
--                        stay_focused, suppress_event, immediate, no_vrr,
--                        no_screen_share, render_unfocused, tag, content
-- Layer surfaces (bars, notifications) use hl.layer_rule() instead.
-- ===========================================================================

-- ── Workspace assignments ─────────────────────────────────────────────────────
-- Workspace layout:
--   1  regular apps (no rule needed)
--   2  games and fullscreen apps
--   3  game launchers (Steam, Prism Launcher, Faugus)

hl.window_rule({ match = { class = "^steam$"                               }, workspace = "3 silent" })
hl.window_rule({ match = { class = "org.prismlauncher.PrismLauncher"       }, workspace = "3 silent" })
hl.window_rule({ match = { class = "faugus-launcher"                       }, workspace = "3 silent" })

-- Games → workspace 2. Proton and Steam games are moved by
-- scripts/game-workspace.sh instead: rules apply when the window opens,
-- before Steam's fullscreen request arrives.
hl.window_rule({ match = { class = "gamescope"         }, workspace = "2 silent" })
hl.window_rule({ match = { class = "lutris"            }, workspace = "2 silent" })
hl.window_rule({ match = { class = "heroic"            }, workspace = "2 silent" })
hl.window_rule({ match = { class = "minecraft-launcher"}, workspace = "2 silent" })
hl.window_rule({ match = { class = "Minecraft.*"       }, workspace = "2 silent" })
hl.window_rule({ match = { class = "HytaleClient"      }, workspace = "2 silent" })

-- Fullscreen apps → workspace 2. Rules are checked when a window opens, so
-- this only catches windows that open already fullscreen; windows that go
-- fullscreen later are moved by scripts/game-workspace.sh.
hl.window_rule({ match = { fullscreen = true }, workspace = "2 silent" })

-- ── Floating windows ──────────────────────────────────────────────────────────
-- Settings tools and file dialogs open floating instead of tiled.
hl.window_rule({ match = { class = "pavucontrol"       }, float = true })
hl.window_rule({ match = { class = "blueman-manager"   }, float = true })
hl.window_rule({ match = { class = "nm-connection-editor" }, float = true })
hl.window_rule({ match = { class = "nwg-look"          }, float = true })
hl.window_rule({ match = { class = "qt6ct"             }, float = true })
hl.window_rule({ match = { class = "gnome-disks"       }, float = true })
hl.window_rule({ match = { title = "Open File"         }, float = true })
hl.window_rule({ match = { title = "Save File"         }, float = true })
hl.window_rule({ match = { title = "File Upload"       }, float = true })

-- Floating kitty — the quick terminal (kitty --class floating-term) opened
-- by a keybind; half the monitor wide, 60% tall, centered.
hl.window_rule({
    match    = { class = "floating-term" },
    float    = true,
    size     = "(monitor_w*0.5) (monitor_h*0.6)",
    center   = true,
})

-- ── Transparency ──────────────────────────────────────────────────────────────
-- opacity = "ACTIVE [override] [INACTIVE [override] [FULLSCREEN [override]]]"
-- One value applies to all three states. "override" makes the value absolute
-- instead of multiplying it with decoration.active_opacity/inactive_opacity.
-- Kitty: 0.75 focused, 0.6 unfocused; kitty/hyprland-overrides.conf sets
-- kitty's own background_opacity to 1.0 so the two do not stack.
hl.window_rule({
    match   = { class = "kitty" },
    opacity = "0.75 override 0.6 override",
})

-- Nautilus: 0.85 focused, 0.75 unfocused.
hl.window_rule({
    match   = { class = "org.gnome.Nautilus" },
    opacity = "0.85 override 0.75 override",
})

-- ── Launcher (wofi) ───────────────────────────────────────────────────────────
-- wofi rules live in components/launcher.lua, written by nixos-config
-- modules/components/launcher/wofi.nix.

-- Power menu (scripts/powermenu.sh) windows: floating, centered, rounded.
hl.window_rule({ match = { class = "powermenu"       }, rounding = 10 })
hl.window_rule({ match = { class = "powermenu"       }, float    = true })
hl.window_rule({ match = { class = "powermenu"       }, center   = true })
hl.window_rule({ match = { class = "powermenu-small" }, rounding = 10 })
hl.window_rule({ match = { class = "powermenu-small" }, float    = true })
hl.window_rule({ match = { class = "powermenu-small" }, center   = true })

-- ── Picture-in-picture ────────────────────────────────────────────────────────
-- Browser PiP video: floating, pinned to all workspaces, aspect ratio kept.
hl.window_rule({ match = { title = "Picture-in-Picture" }, float             = true })
hl.window_rule({ match = { title = "Picture-in-Picture" }, pin               = true })
hl.window_rule({ match = { title = "Picture-in-Picture" }, keep_aspect_ratio = true })

-- ── Wine/Proton — hide ghost windows that keep workspaces marked as occupied ──
-- wineserver keeps helper windows open after a Wine/Proton app closes (the
-- explorer.exe desktop process, XEmbed tray icons). They are sent to the
-- special workspace "hidden" so they do not mark workspaces 2/3 as occupied.

-- Battle.net XEmbed tray icon (160x20, empty title).
hl.window_rule({ match = { class = "steam_app_default", title = "^$" }, float     = true              })
hl.window_rule({ match = { class = "steam_app_default", title = "^$" }, workspace = "special:hidden"  })

-- Wine's desktop process (explorer.exe) while wineserver runs. A real Wine
-- explorer window has a title, so only the untitled one is hidden.
hl.window_rule({ match = { class = "explorer.exe",      title = "^$" }, workspace = "special:hidden"  })

-- ── XWayland ─────────────────────────────────────────────────────────────────
-- No corner rounding on X11 (XWayland) windows.
hl.window_rule({ match = { xwayland = true }, rounding = 0 })
-- Battle.net — rounding back on; later rules override earlier ones.
hl.window_rule({ match = { class = "steam_app_default" }, rounding = 10 })

-- ── Idle inhibit ─────────────────────────────────────────────────────────────
-- idle_inhibit modes: none, always, focus (while focused), fullscreen (while
-- fullscreen). Any fullscreen window blocks idle; mpv blocks it while focused.
hl.window_rule({ match = { class = ".*" },   idle_inhibit = "fullscreen" })
hl.window_rule({ match = { class = "mpv" },  idle_inhibit = "focus"      })

-- ── Layer rules ──────────────────────────────────────────────────────────────
-- swaync layer rules live in components/notifications.lua, written by
-- nixos-config modules/components/notifications/swaync/swaync.nix.
