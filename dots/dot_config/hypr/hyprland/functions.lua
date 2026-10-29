-- ~/.config/hypr/hyprland/functions.lua
-- dream-wa1ker

local boot = require("core.bootstrap")

local function noctalia(command)
    return hl.dsp.exec_cmd("noctalia msg " .. command)
end

local function addr(win)
    return win and win.address and ("address:" .. win.address) or nil
end

local function wsaction(action, range, i)
    return function()
        local activews = hl.get_active_workspace()
        if activews then
            local id = activews.id
            local slot = ((id - 1) % 10) + 1
            local s = (i - 1) * 10 + slot
            local t  = math.floor((id - 1) / 10) * 10 + i
            local z  = (range == "group") and s or t

            if action == "move" then
                return hl.dispatch(hl.dsp.window.move({ workspace = z }))
            else
                return hl.dispatch(hl.dsp.focus({ workspace = z }))
            end
        end
    end
end

local function resize_by_screen(x, y)
    local screen = hl.get_active_monitor()
    if screen and type(screen.width) == "number" and type(screen.height) == "number" then
        if not (x == 0 and y == 0) then
            local w = (x and x > 0) and math.floor(screen.width * x / 100) or screen.width
            local h = (y and y > 0) and math.floor(screen.height * y / 100) or screen.height
            return { x = w, y = h, relative = false }
        end
    end
end

local function resize_screen(x, y)
    return function()
        local res = resize_by_screen(x, y)
        if res then
            hl.dispatch(hl.dsp.window.resize(res))
        end
    end
end

local function resize_active_window(x, y)
    local win = hl.get_active_window()
    if win and win.size and win.size.x and win.size.y then
        local w = win.size.x * (x / 100)
        local h = win.size.y * (y / 100)
        return { x = w, y = h, relative = true }
    end
end

local function resize_active(x, y)
    return function()
        local res = resize_active_window(x, y)
        if res then
            hl.dispatch(hl.dsp.window.resize(res))
        end
    end
end

local function resizer(window, pattern, x_percent, y_percent, actions, exact)
    if (window and window.title) and string.find(window.title, pattern, 1, exact) then
        local disp = (type(actions) == "table") and actions or { actions }
        for _, a in ipairs(disp) do
            hl.dispatch(a)
        end

        hl.dispatch(hl.dsp.window.resize(resize_by_screen(x_percent, y_percent)))
        hl.dispatch(hl.dsp.window.set_prop({ prop = "keep_aspect_ratio", value = "true" }))
    end
end

local function move_actions(win)
    local screen = win and (win.monitor or hl.get_active_monitor())
    if not (screen and win.size and win.size.x and win.size.y
        and win.size.x > 0 and win.size.y > 0) then
        return nil
    end

    -- In 0.57, mode contains logical dimensions, including scale/rotation.
    local mode = screen.mode
    if not (mode and mode.width and mode.height) then return nil end
    local reserved = screen.reserved or {}
    local left, top = reserved.left or 0, reserved.top or 0
    local width = mode.width - left - (reserved.right or 0)
    local height = mode.height - top - (reserved.bottom or 0)
    if width <= 0 or height <= 0 then return nil end

    local margin = math.floor(math.min(width, height) * 0.03)
    -- One scale factor preserves aspect ratio, even for very wide windows.
    local factor = math.min(height * 0.25 / win.size.y, width * 0.40 / win.size.x)
    local w = math.max(1, math.floor(win.size.x * factor))
    local h = math.max(1, math.floor(win.size.y * factor))

    return {
        hl.dsp.window.resize({ x = w, y = h, relative = false, window = addr(win) }),
        hl.dsp.window.move({
            x = math.floor(screen.x + left + width - w - margin),
            y = math.floor(screen.y + top + height - h - margin),
            relative = false, window = addr(win),
        }),
    }
end

-- Logical monitor size (accounts for scale), or nil if unavailable.
local function monitor_size()
    local m = hl.get_active_monitor()
    if m and type(m.width) == "number" and type(m.height) == "number" then
        local s = (type(m.scale) == "number" and m.scale > 0) and m.scale or 1
        return m.width / s, m.height / s
    end
end

-- Pixel size of a float rule on the active monitor.
local function rule_pixels(r)
    if r.wp and r.hp then
        local mw, mh = monitor_size()
        if mw then
            return math.floor(mw * r.wp), math.floor(mh * r.hp)
        end
    end
    return r.w or 1000, r.h or 600   -- pixel rule, or fallback without monitor info
end

local function floatSpawnRule(appKey, extra)
    local vars = require("hyprland.variables")
    local class = vars.floatCommandClasses[appKey] or appKey
    local r = vars.floatRules[class] or vars.defaultRule
    local eff = {}
    if r.wp and r.hp then
        eff.size = ("(monitor_w*%s) (monitor_h*%s)"):format(r.wp, r.hp)
    else
        eff.size = r.w .. " " .. r.h
    end

    if r.x and r.y then
        eff.move = { r.x, r.y }
    end

    for k, v in pairs(extra or {}) do
        eff[k] = v
    end

    return eff
end

------------------------------------------------------------------
-- Migrated Actions from keybinds.lua
------------------------------------------------------------------

-- Snapshots are per window, not a global "PiP enabled" flag.
local pip_states = {}

local function pip_dispatch(action)
    local result = hl.dispatch(action)
    if type(result) == "table" and result.ok == false then
        error(result.error or "PiP action failed")
    end
end

local function pip_fullscreen(win, internal, client, layout_aware)
    pip_dispatch(hl.dsp.window.fullscreen_state({
        window = addr(win), action = "set",
        internal = internal, client = client, layout_aware = layout_aware,
    }))
end

local function restore_pip(win, state)
    local target = addr(win)
    -- Unpin before restoring tiling or fullscreen; both can reject pinned windows.
    pip_fullscreen(win, 0, 0, state.layout_aware)
    if win.pinned then
        pip_dispatch(hl.dsp.window.pin({ window = target, action = "off" }))
    end
    if state.floating then
        pip_dispatch(hl.dsp.window.float({ window = target, action = "on" }))
        pip_dispatch(hl.dsp.window.resize({
            window = target, x = state.width, y = state.height, relative = false,
        }))
        pip_dispatch(hl.dsp.window.move({
            window = target, x = state.x, y = state.y, relative = false,
        }))
    else
        -- Let the current layout place a formerly tiled window.
        pip_dispatch(hl.dsp.window.float({ window = target, action = "off" }))
    end
    if state.pinned then
        pip_dispatch(hl.dsp.window.pin({ window = target, action = "on" }))
    end
    if state.fullscreen ~= 0 or state.fullscreen_client ~= 0 then
        pip_fullscreen(win, state.fullscreen, state.fullscreen_client, state.layout_aware)
    end
end

local toggle_pip = boot.safe_call(function()
    local win = hl.get_active_window()
    if not (win and win.mapped and win.stable_id and win.address) then return end

    local id = win.stable_id
    local saved = pip_states[id]
    if saved then
        restore_pip(win, saved)
        pip_states[id] = nil -- retain the snapshot if restoration fails
        return
    end

    local actions = move_actions(win)
    if not (actions and win.at and win.at.x and win.at.y) then return end
    saved = {
        address = win.address,
        floating = win.floating, pinned = win.pinned,
        x = win.at.x, y = win.at.y,
        width = win.size.x, height = win.size.y,
        fullscreen = win.fullscreen or 0,
        fullscreen_client = win.fullscreen_client or 0,
        layout_aware = win.fullscreen_handler ~= "default",
    }
    pip_states[id] = saved

    local ok, err = pcall(function()
        pip_fullscreen(win, 0, 0, saved.layout_aware)
        pip_dispatch(hl.dsp.window.float({ window = addr(win), action = "on" }))
        for _, action in ipairs(actions) do pip_dispatch(action) end
        pip_dispatch(hl.dsp.window.pin({ window = addr(win), action = "on" }))
    end)
    if not ok then
        -- Roll back partial entry. Keep the snapshot if rollback also fails.
        local restored = pcall(restore_pip, win, saved)
        if restored then pip_states[id] = nil end
        error(err)
    end
end, "kbWindowPip")

hl.on("window.close", function(win)
    if win and win.stable_id then pip_states[win.stable_id] = nil end
end)

-- Lua state is discarded on reload: restore windows before losing their snapshots.
hl.on("config.unload", function()
    for id, state in pairs(pip_states) do
        local win = hl.get_window("address:" .. state.address)
        if win and win.mapped and win.stable_id == id then
            boot.safe_call(restore_pip, "PiP restore on unload")(win, state)
        end
    end
end)

local toggle_floating = boot.safe_call(function()
    local vars = require("hyprland.variables")
    hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
    local w = hl.get_active_window()
    if w and w.floating then
        local class = w.class and w.class:lower() or ""
        local rule = vars.floatRules[class] or vars.defaultRule

        local w_px, h_px = rule_pixels(rule)
        hl.dispatch(hl.dsp.window.resize({ exact = true, x = w_px, y = h_px }))

        if rule.x and rule.y then
            hl.dispatch(hl.dsp.window.move({ exact = true, x = rule.x, y = rule.y }))
        else
            hl.dispatch(hl.dsp.window.center())
        end
    end
end, "kbToggleWindowFloating")

local function cycle_workspace_layout(layouts)
    return boot.safe_call(function()
        local workspace = hl.get_active_workspace()
        if hl.get_active_special_workspace() then
            workspace = hl.get_active_special_workspace()
        end

        local next_layout = "dwindle"

        if not workspace then
            return
        end

        for i = 1, #layouts do
            if layouts[i] == workspace.tiled_layout then
                local next_layout_idx = (i % #layouts) + 1
                next_layout = layouts[next_layout_idx]
                break
            end
        end

        if workspace.special then
            hl.workspace_rule({ workspace = tostring(workspace.name), layout = next_layout })
        else
            hl.workspace_rule({ workspace = tostring(workspace.id), layout = next_layout })
        end
    end)
end

local cycle_all_layouts = cycle_workspace_layout({ "scrolling", "dwindle", "master", "monocle" })
local toggle_scroll_layout = cycle_workspace_layout({ "scrolling", "dwindle" })

return {
    addr                  = addr,
    resizer               = resizer,
    resize_by_screen      = resize_by_screen,
    resize_screen         = resize_screen,
    resize_active_window  = resize_active_window,
    resize_active         = resize_active,
    wsaction              = wsaction,
    move_actions          = move_actions,
    floatSpawnRule        = floatSpawnRule,
    toggle_pip            = toggle_pip,
    toggle_floating       = toggle_floating,
    cycle_all_layouts     = cycle_all_layouts,
    toggle_scroll_layout  = toggle_scroll_layout,
    noctalia              = noctalia,
}
