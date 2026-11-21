-- ===========================================================================
-- modules/autostart.lua — Apps and daemons that start with Hyprland
--
-- Required by hyprland.lua. hl.on(event, fn) runs fn when the event fires;
-- "hyprland.start" fires once when the compositor starts, not on
-- `hyprctl reload`. Other events include "hyprland.shutdown",
-- "config.reloaded", "monitor.added", "workspace.active" and window/layer
-- open and close events.
--
-- hl.exec_cmd(cmd [, rules]) runs cmd through the shell; the optional table
-- applies window rules to the window the command opens.
-- Shell launch commands (if any) live in shell-autostart.lua, which
-- hyprland.lua loads after this file.
-- ===========================================================================

hl.on("hyprland.start", function()

    -- ── Idle management ───────────────────────────────────────────────────────
    -- hypridle reads ~/.config/hypr/hypridle.conf (hypridle-laptop.conf or
    -- hypridle-desktop.conf, chosen per host by nixos-config).
    hl.exec_cmd("hypridle")

    -- ── Polkit authentication agent ───────────────────────────────────────────
    -- Shows the password dialog when an app asks polkit for elevated rights
    -- (pkexec, gvfs mounts, etc.). Installed by the Hyprland NixOS module.
    hl.exec_cmd("/run/current-system/sw/libexec/polkit-gnome-authentication-agent-1")

    -- ── Secret storage — GNOME Keyring daemon ─────────────────────────────────
    -- Runs the keyring daemon inside the UWSM session so it lives as long as
    -- the session; a daemon started by PAM at login does not survive the move
    -- into UWSM's systemd scope. The login keyring must have an empty
    -- password to unlock without a prompt.
    --   --start             start a daemon, or set up one that is running
    --   --daemonize         run in the background
    --   --components=LIST   pkcs11 and/or secrets; only secrets here
    --   alternatives: --replace, --foreground, --login, --unlock
    hl.exec_cmd("gnome-keyring-daemon --start --daemonize --components=secrets")

    -- ── System tray daemons ───────────────────────────────────────────────────
    -- None started here:
    --   network, bluetooth  handled by the shell's bar widgets (no nm-applet
    --                       or blueman-applet)
    --   openrgb             a systemd service runs `openrgb --server`; the GUI
    --                       opens from the launcher

    -- ── Clipboard history — wl-clipboard + cliphist ───────────────────────────
    -- wl-paste --watch runs `cliphist store` on every clipboard change;
    -- --type limits each watcher to text or images. SUPER+V opens the history
    -- picker (bound in components/launcher.lua).
    hl.exec_cmd("wl-paste --type text  --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")

    -- ── Host-specific overrides ───────────────────────────────────────────────
    -- scripts/host-overrides.sh — sets per-host values (e.g. window opacity
    -- for the display type) with hyprctl after startup.
    hl.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/host-overrides.sh")

    -- ── Game workspace ────────────────────────────────────────────────────────
    -- scripts/game-workspace.sh — moves Proton and native Wayland game
    -- windows to workspace 2. Window rules apply before Steam's fullscreen
    -- request arrives, so the script listens for openwindow events on the
    -- Hyprland socket and moves the window once it has settled.
    hl.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/game-workspace.sh")

end)
