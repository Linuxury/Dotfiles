-- ===========================================================================
-- modules/appearance.lua — Visual style: gaps, borders, blur, animations
--
-- Required by hyprland.lua after colors. Sets gaps, borders, blur, shadows,
-- animations, layout options, workspace rules and render/misc options.
-- Options not set here keep Hyprland's defaults.
--
-- Colors (primary, tertiary, outline_variant, …) are globals defined by
-- colors.lua, which matugen writes from colors.lua.template. Until it exists
-- the border-color block is skipped and Hyprland's default colors are used;
-- the matugen user timer (hyprland-matugen.nix in nixos-config) runs it 10 s
-- after the session starts.
-- ===========================================================================

-- ── Layout + borders ─────────────────────────────────────────────────────────
-- general — set here: gaps_in (between windows, default 5), gaps_out (to the
-- screen edge, default 20), border_size (default 1), layout, resize_on_border.
--   layout  dwindle (default), master, scrolling, monocle, or lua:<name>
-- Other options: float_gaps, gaps_workspaces, extend_border_grab_area,
-- hover_icon_on_border, allow_tearing, resize_corner, no_focus_fallback.
hl.config({
    general = {
        gaps_in          = 5,
        gaps_out         = 10,
        border_size      = 2,
        layout           = "scrolling",
        resize_on_border = true,    -- Drag window edges to resize
    },
})

-- Border colors from matugen, applied only when colors.lua has loaded.
--   col.active_border    a color, or { colors = {...}, angle = degrees } for
--                        a gradient
--   col.inactive_border  same forms
if primary then
    hl.config({
        general = {
            col = {
                -- Two-color gradient at 45° on the focused window
                active_border   = { colors = { primary, tertiary }, angle = 45 },
                inactive_border = outline_variant,
            },
        },
    })
end

-- ── Decoration ───────────────────────────────────────────────────────────────
hl.config({
    decoration = {
        rounding = 10,

        -- rounding = corner radius in layout px (default 0). Other options:
        -- rounding_power (2 = circle), active_opacity, inactive_opacity,
        -- fullscreen_opacity, dim_inactive, dim_strength, dim_special,
        -- screen_shader, plus glow, motion_blur and wobble sub-sections.
        --
        -- Blur behind transparent windows (kitty, waybar, wofi).
        --   size               blur distance (default 8)
        --   passes             number of passes (default 1); more = stronger
        --   new_optimizations  extra blur optimizations (default true)
        --   vibrancy           saturation boost for blurred colors
        --                      (default 0.1696)
        -- Other options: ignore_opacity, xray, noise, contrast, brightness,
        -- vibrancy_darkness, special, popups, input_methods, proportional.
        blur = {
            enabled           = true,
            size              = 8,
            passes            = 2,
            new_optimizations = true,
            vibrancy          = 0.17,
        },

        -- Drop shadows.
        --   range         size in layout px (default 4)
        --   render_power  falloff power 1-4; higher = faster falloff (default 3)
        --   color         rgba(RRGGBBAA); alpha sets the shadow opacity
        -- Other options: sharp, color_inactive, scale.
        shadow = {
            enabled      = true,
            range        = 12,
            render_power = 3,
            color        = "rgba(00000055)",
        },
    },
})

-- ── Animation curves ─────────────────────────────────────────────────────────
-- hl.curve(name, def) defines a named curve for hl.animation.
--   type = "bezier"  points = two control points { {x1, y1}, {x2, y2} };
--                    y outside 0-1 overshoots
--   type = "spring"  mass, stiffness, dampening
-- "default" is built in.
hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1}    } })
hl.curve("easeInOutSine",  { type = "bezier", points = { {0.37, 0},    {0.63, 1}    } })
hl.curve("easeOutBack",    { type = "bezier", points = { {0.34, 1.56}, {0.64, 1}    } })   -- Slight overshoot
hl.curve("easeInBack",     { type = "bezier", points = { {0.36, 0},    {0.66, -0.56} } })   -- Pulls inward before closing
hl.curve("linear",         { type = "bezier", points = { {0,    0},    {1,    1}    } })

-- ── Animations ───────────────────────────────────────────────────────────────
-- animations.enabled turns all animations on/off (default true).
-- hl.animation({ leaf, enabled, speed, bezier | spring, style }):
--   leaf    node of the animation tree. global → windows (windowsIn,
--           windowsOut, windowsMove), layers (layersIn, layersOut), fade
--           (fadeIn, fadeOut, fadeSwitch, fadeShadow, fadeDim, fadeLayers,
--           fadePopups, fadeDpms, ...), border, borderangle, workspaces
--           (workspacesIn, workspacesOut, specialWorkspace), zoomFactor,
--           monitorAdded. A child without its own entry inherits its parent.
--   speed   0-100, the animation duration; higher = slower
--   style   windows: popin [%], slide, gnomed; workspaces: slide,
--           slidevert, slidefade, slidefadevert; borderangle: once, loop
hl.config({ animations = { enabled = true } })

-- Windows
hl.animation({ leaf = "windows",     enabled = true, speed = 5,  bezier = "easeOutBack",   style = "popin"    })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 4,  bezier = "easeInBack",    style = "popin"    })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 4,  bezier = "easeOutQuint"                      })

-- Borders
hl.animation({ leaf = "border",      enabled = true, speed = 6,  bezier = "default"                           })
hl.animation({ leaf = "borderangle", enabled = true, speed = 60, bezier = "linear",        style = "loop"     })   -- Rotating gradient

-- Fades
hl.animation({ leaf = "fade",        enabled = true, speed = 4,  bezier = "easeInOutSine"                     })
hl.animation({ leaf = "fadeOut",     enabled = true, speed = 4,  bezier = "easeInOutSine"                     })

-- Workspaces
hl.animation({ leaf = "workspaces",  enabled = true, speed = 5,  bezier = "easeOutBack",   style = "slide"         })

-- ── Layout options ────────────────────────────────────────────────────────────
-- Options for each layout; only the one named in general.layout is active.
-- dwindle (binary tree splits):
--   preserve_split  keep a split's direction whatever happens to the container
--   smart_split     pick the split direction from the cursor position
--   smart_resizing  pick the resize direction from the cursor position
--   others: force_split, default_split_ratio, split_bias, special_scale_factor,
--           permanent_direction_override, use_active_for_splits
-- master:
--   new_status  where new windows go: master, slave (default), inherit
--   others: mfact, orientation, new_on_top, new_on_active, allow_small_split
-- scrolling (columns that scroll sideways):
--   fullscreen_on_one_column  a lone column spans the screen (default true)
--   column_width              default column width, 0.1-1.0 (default 0.5)
--   direction                 where new columns appear and the view scrolls
--   focus_fit_method          bring a focused column into view: 0 center,
--                             1 fit (default)
--   explicit_column_widths    widths that colresize +conf/-conf cycles through
--   follow_focus              0 focus never scrolls the view, 1 focus may
--                             scroll it and a click always does, 2 focus may
--                             scroll it (true = 1)
--   others: follow_min_visible, wrap_focus, wrap_swapcol
hl.config({
    dwindle = {
        preserve_split  = true,   -- Split direction is remembered per-split
        smart_split     = false,
        smart_resizing  = true,
    },
    master = {
        new_status = "master",
    },
    scrolling = {
        fullscreen_on_one_column = false,
        column_width             = 0.75,   -- 75%: single-window/new-column width; layout-hooks.lua
                                           -- dynamically adjusts to 50% when 2+ windows exist.
        direction                = "right",
        focus_fit_method         = 1,
        explicit_column_widths   = "0.333, 0.5, 0.667, 1.0",
        follow_focus             = true,
    },
})

-- ── Workspace rules ──────────────────────────────────────────────────────────
-- Workspaces 1-9 are persistent, so they exist even when empty (the
-- Noctalia bar shows every persistent workspace). No per-workspace layout is
-- set; Super+backslash cycles the layout.
-- hl.workspace_rule() fields: workspace (required), persistent, default,
--   monitor, default_name, layout, gaps_in, gaps_out, float_gaps,
--   border_size, no_border, no_rounding, decorate, no_shadow,
--   on_created_empty, animation
for i = 1, 9 do
    hl.workspace_rule({
        workspace  = tostring(i),
        persistent = true,
        default    = (i == 1),   -- workspace 1 is the landing workspace on each monitor
    })
end

-- ── Render + misc ─────────────────────────────────────────────────────────────
-- render:
--   direct_scanout  0 disable (default), 1 enable, 2 auto: send a fullscreen
--                   window straight to the display, skipping composition
--   cm_auto_hdr     switch the monitor to HDR while an HDR app is fullscreen:
--                   0 disable, 1 hdr (default), 2 hdredid (HDR with the
--                   monitor's EDID values)
--   others: cm_enabled, cm_sdr_eotf, send_content_type, use_fp16,
--           new_render_scheduling, ctm_animation
-- misc:
--   force_default_wallpaper   -1 random, 0-2 pick one of Hyprland's
--                             wallpapers; 0 here, the shell draws its own
--   disable_hyprland_logo     hide the default background logo
--   disable_splash_rendering  hide the splash text
--   mouse_move_enables_dpms   wake screens on mouse movement
--   key_press_enables_dpms    wake screens on key press
--   animate_manual_resizes    animate windows resized/moved by hand
--   others: vrr (global VRR default), focus_on_activate, enable_swallow,
--           background_color, font_family
hl.config({
    render = {
        direct_scanout = 0,   -- Disabled — causes flickering when entering/leaving fullscreen
        -- 2 = hdredid. Proton games must run as native Wayland clients
        -- (PROTON_ENABLE_WAYLAND=1) to be seen as HDR-capable.
        cm_auto_hdr = 2,
    },
    misc = {
        force_default_wallpaper  = 0,
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,
        mouse_move_enables_dpms  = true,
        key_press_enables_dpms   = true,
        animate_manual_resizes   = true,
        -- VRR is set per monitor in monitors.lua (DP-3 only), not with
        -- misc.vrr, as the ThinkPad panel has no VRR.
    },
})
