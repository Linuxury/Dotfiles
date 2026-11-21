-- ===========================================================================
-- modules/environment.lua — Environment variables
--
-- Environment variables for the Hyprland session. Required by hyprland.lua.
--
-- hl.env(name, value [, dbus]) calls setenv() in the compositor, so every
-- process Hyprland starts inherits the variable. Arguments:
--   name, value  strings; an empty name is an error
--   dbus         optional boolean, default false. true also runs
--                `systemctl --user import-environment` and
--                `dbus-update-activation-environment --systemd` for the
--                name, so D-Bus- and systemd-started services see it too
-- On reload, a variable that already holds the same value is left alone.
-- ===========================================================================

-- Cursor — BreezeX-Light, an XCursor theme. home.pointerCursor in
-- nixos-config modules/themes/gtk.nix installs it. These variables make apps
-- started from Hyprland use the same theme and size.
--   XCURSOR_THEME, XCURSOR_SIZE      XCursor theme name and size in pixels
--   HYPRCURSOR_THEME, HYPRCURSOR_SIZE  hyprcursor-format theme; not set, as
--                                    no hyprcursor theme is installed
hl.env("XCURSOR_THEME", "BreezeX-Light")
hl.env("XCURSOR_SIZE",  "24")

-- Session identity — tells apps and portals which desktop and session
-- type they run under (xdg-desktop-portal picks its backend from
-- XDG_CURRENT_DESKTOP).
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE",    "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

-- GTK — GDK_BACKEND is a comma-separated list of backends to try in order;
-- "*" means any other available backend.
hl.env("GDK_BACKEND", "wayland,x11,*")

-- Qt
--   QT_QPA_PLATFORM                      platform plugins to try, ";"-separated
--                                        (wayland first, then xcb = X11)
--   QT_QPA_PLATFORMTHEME                 platform theme plugin (qt6ct = settings
--                                        from the qt6ct tool; alternatives:
--                                        gtk3, kde, or unset)
--   QT_STYLE_OVERRIDE                    widget style for all Qt apps
--                                        (e.g. kvantum, Fusion, Adwaita-Dark)
--   QT_WAYLAND_DISABLE_WINDOWDECORATION  1 = no client-side title bars
hl.env("QT_QPA_PLATFORM",                 "wayland;xcb")
hl.env("QT_QPA_PLATFORMTHEME",            "qt6ct")
hl.env("QT_STYLE_OVERRIDE",               "Adwaita-Dark")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")

-- Firefox / Electron — run as native Wayland clients.
--   MOZ_ENABLE_WAYLAND            1 = Firefox uses its Wayland backend
--   ELECTRON_OZONE_PLATFORM_HINT  auto = Wayland when available, else X11
--                                 (alternatives: wayland, x11)
hl.env("MOZ_ENABLE_WAYLAND",           "1")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

-- Java AWT apps (e.g. Minecraft launchers) — 1 tells AWT the window manager
-- does not reparent windows; without it AWT windows can draw blank under
-- tiling compositors.
hl.env("_JAVA_AWT_WM_NONREPARENTING", "1")
