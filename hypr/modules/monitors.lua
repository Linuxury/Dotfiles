-- ===========================================================================
-- modules/monitors.lua — Monitor layout
--
-- Monitor rules, one hl.monitor() call per output. Required by hyprland.lua.
-- Shared by every linuxury host; outputs without a named rule use the
-- catch-all rule at the bottom. A second rule for the same output name starts
-- from the earlier one and changes only the fields it sets.
--
-- hl.monitor() fields (an unknown field is a config error):
--   output         connector name, e.g. "DP-3" (required); "" = any output
--                  without its own rule
--   mode           "WxH@Hz", "preferred" (default), "highres", "highrr"
--   position       "XxY" or "auto" (default; also auto-right/left/up/down)
--   scale          number as a string, or "auto" (default)
--   transform      0-7 rotation/flip (default 0)
--   mirror         output name to mirror
--   disabled       true turns the output off
--   bitdepth       8 (default) or 10
--   cm             color mode: srgb (default), auto, wide, edid, hdr,
--                  hdredid, dcip3, dp3, adobe
--   vrr            unset = use misc:vrr; 0 off, 1 on, 2 fullscreen only,
--                  3 fullscreen game/video content only
--   icc            path to an ICC profile
--   sdr_eotf, sdrbrightness, sdrsaturation, sdr_min_luminance,
--   sdr_max_luminance, min_luminance, max_luminance, max_avg_luminance,
--   supports_wide_color, supports_hdr   HDR/SDR tuning and capability overrides
--   reserved_area  space kept free at the edges (CSS-style gap)
-- ===========================================================================

-- Ryzen5900x — LG 34" ultrawide (3440x1440, 240Hz)
--   bitdepth 10  10-bit color output
--   cm "srgb"    SDR desktop; render.cm_auto_hdr (appearance.lua) switches
--                to HDR only while an HDR fullscreen app runs. "wide"/"auto"
--                are the alternatives; see hyprwm/Hyprland#12971 for why
--                they are not used here.
hl.monitor({
    output   = "DP-3",
    mode     = "3440x1440@240",
    position = "0x0",
    scale    = "1",
    bitdepth = 10,
    cm       = "srgb",
    vrr      = 2,   -- fullscreen-only VRR (avoids flickering on the desktop)
})

-- Catch-all — ThinkPad built-in display and any output without its own rule:
-- preferred mode, automatic position and scale.
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})
