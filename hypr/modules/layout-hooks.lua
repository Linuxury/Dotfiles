-- ===========================================================================
-- modules/layout-hooks.lua — Dynamic layout behaviors
--
-- Required by hyprland.lua. Sets column widths automatically when
-- general.layout is "scrolling"; does nothing in other layouts.
--   1 tiled window    width = scrolling.column_width (set in appearance.lua)
--   2+ tiled windows  every column 50%
-- Floating windows are not counted.
--
-- Runs on these events (hl.on):
--   window.open, window.destroy  deferred one event-loop tick (see below)
--   workspace.active             runs at once
--
-- Uses Lua dispatchers only: hl.dispatch(hl.dsp.layout("colresize X")) to
-- resize the focused column and hl.dsp.focus({ direction = "left"|"right" })
-- to move between columns.
-- hl.timer(fn, { timeout = ms, type = "oneshot"|"repeat" }) runs fn after
-- timeout ms (must be > 0), once or repeatedly.
-- ===========================================================================

local function _apply_col_width()
    local ws = hl.get_active_workspace()
    if not ws then return end

    -- Only run in scrolling layout
    local layout = hl.get_config("general.layout")
    if layout ~= "scrolling" then return end

    -- Count non-floating tiled windows on this workspace
    local wins = hl.get_workspace_windows(ws)
    local n = 0
    for _, w in ipairs(wins) do
        if not w.floating then n = n + 1 end
    end

    if n == 0 then return end

    -- Single window: resize current column and done.
    if n == 1 then
        local w = hl.get_config("scrolling.column_width")
        hl.dispatch(hl.dsp.layout("colresize " .. tostring(w)))
        return
    end

    -- Multiple windows: n focus-left moves always reach the leftmost column,
    -- then sweep right resizing each column. On window.open the new window is
    -- focused and rightmost, so the sweep ends back on it.
    local steps = {}
    for _ = 1, n do
        steps[#steps + 1] = function() hl.dispatch(hl.dsp.focus({ direction = "left" })) end
    end
    for _ = 1, n do
        steps[#steps + 1] = function() hl.dispatch(hl.dsp.layout("colresize 0.50")) end
        steps[#steps + 1] = function() hl.dispatch(hl.dsp.focus({ direction = "right" })) end
    end

    -- The viewport scrolls the focused column into view on each focus change.
    -- The last focus change above happens before the final column is
    -- resized, so one more left/right hop makes the view fit the final widths.
    steps[#steps + 1] = function() hl.dispatch(hl.dsp.focus({ direction = "left" })) end
    steps[#steps + 1] = function() hl.dispatch(hl.dsp.focus({ direction = "right" })) end

    -- Dispatches sent in one synchronous Lua call are coalesced: only the
    -- last of each type applies. Running one step per event-loop tick
    -- (chained 1 ms oneshot timers) lets each resize apply.
    local function run_step(i)
        if i > #steps then return end
        steps[i]()
        hl.timer(function() run_step(i + 1) end, { timeout = 1, type = "oneshot" })
    end
    run_step(1)

    -- After the sweep, focus is at the new (rightmost) column — stay there.
end

-- window.open and window.destroy fire before focus and layout state have
-- settled, so a sweep started inside the handler only reaches the focused
-- window. A 1 ms oneshot timer lets the handler return first.
hl.on("window.open",      function() hl.timer(_apply_col_width, { timeout = 1, type = "oneshot" }) end)
hl.on("window.destroy",   function() hl.timer(_apply_col_width, { timeout = 1, type = "oneshot" }) end)
hl.on("workspace.active", function() _apply_col_width() end)
