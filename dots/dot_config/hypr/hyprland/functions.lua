-- ~/.config/hypr/hyprland/functions.lua
-- dream-wa1ker

local boot = require("core.bootstrap")
local geometry = require("hyprland.lib.geometry")

local function noctalia(command)
    return hl.dsp.exec_cmd("noctalia msg " .. command)
end

local function addr(win)
    return win and win.address and ("address:" .. win.address) or nil
end

-- Canonical selectors cover numbered, named, and special workspaces.
local function workspace_selector(workspace)
    local selector = workspace and workspace.addressable_name
    if type(selector) == "string" and selector ~= "" then return selector end
end

local function wsaction(action, range, i)
    return function()
        local activews = hl.get_active_workspace()
        if activews then
            -- Named workspaces use workspace 1 as the group/slot reference.
            local id = type(activews.id) == "number" and activews.id or 1
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

local function window_monitor(win)
    return win and win.monitor or hl.get_active_monitor()
end

local function dispatch_geometry(action)
    local result = hl.dispatch(action)
    if type(result) == "table" and result.ok == false then
        error(result.error or "Window geometry action failed")
    end
end

local function resize_by_screen(x, y, win)
    if x == 0 and y == 0 then return nil end
    win = win or hl.get_active_window()
    local monitor = window_monitor(win)
    local area = geometry.monitor_area(monitor)
    local bounds = win and win.floating and geometry.monitor_area(monitor, true) or nil
    local spec = {
        wp = (type(x) == "number" and x > 0) and x / 100 or 1,
        hp = (type(y) == "number" and y > 0) and y / 100 or 1,
    }
    local size = geometry.resolve_size(spec, area, bounds)
    if not size then return nil end
    return { x = size.width, y = size.height, relative = false, window = addr(win) }
end

local function keep_visible(win, size)
    if not (win and win.floating and win.at) then return end
    local monitor = window_monitor(win)
    local area = geometry.monitor_area(monitor)
    local bounds = geometry.monitor_area(monitor, true)
    if not (area and bounds) then return end
    local position = geometry.resolve_position({
        x = win.at.x - area.x, y = win.at.y - area.y,
    }, area, { width = size.x, height = size.y }, bounds)
    if position and (position.x ~= win.at.x or position.y ~= win.at.y) then
        dispatch_geometry(hl.dsp.window.move({
            window = addr(win), x = position.x, y = position.y, relative = false,
        }))
    end
end

local function resize_screen(x, y)
    return boot.safe_call(function()
        local win = hl.get_active_window()
        if not (win and win.address) then return end
        local res = resize_by_screen(x, y, win)
        if res then
            dispatch_geometry(hl.dsp.window.resize(res))
            keep_visible(win, res)
        end
    end, "resizeScreen")
end

local function resize_active_window(x, y)
    local win = hl.get_active_window()
    if win and win.size and win.size.x and win.size.y then
        local w = win.size.x * (x / 100)
        local h = win.size.y * (y / 100)
        return { x = w, y = h, relative = true, window = addr(win) }
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
        for _, action in ipairs(disp) do hl.dispatch(action) end
        local res = resize_by_screen(x_percent, y_percent, window)
        if res then
            dispatch_geometry(hl.dsp.window.resize(res))
            keep_visible(window, res)
            dispatch_geometry(hl.dsp.window.set_prop({
                window = addr(window), prop = "keep_aspect_ratio", value = "true",
            }))
        end
    end
end

local function move_actions(win)
    local screen = win and window_monitor(win)
    local box = geometry.pip_box(geometry.monitor_area(screen, true), win and win.size)
    if not box then return nil end
    return {
        hl.dsp.window.resize({
            window = addr(win), x = box.width, y = box.height, relative = false,
        }),
        hl.dsp.window.move({
            window = addr(win), x = box.x, y = box.y, relative = false,
        }),
    }
end

local function floatSpawnRule(appKey, extra)
    local vars = require("hyprland.variables")
    local effects, err = geometry.rule_effects(geometry.find_spec(vars, appKey))
    assert(effects, err)
    for key, value in pairs(extra or {}) do effects[key] = value end
    return effects
end

------------------------------------------------------------------
-- Migrated Actions from keybinds.lua
------------------------------------------------------------------

-- Snapshots are per window, not a global "PiP enabled" flag.
local pip_states = {}
local placement_states = {}

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

local function snapshot(win)
    local monitor = window_monitor(win)
    return {
        address = win.address,
        floating = win.floating, pinned = win.pinned,
        x = win.at.x, y = win.at.y,
        width = win.size.x, height = win.size.y,
        fullscreen = win.fullscreen or 0,
        fullscreen_client = win.fullscreen_client or 0,
        layout_aware = win.fullscreen_handler ~= "default",
        monitor_name = monitor and monitor.name,
        monitor_x = monitor and monitor.x or 0,
        monitor_y = monitor and monitor.y or 0,
    }
end

local function restore_placement(win, state)
    local adjusted = {}
    for key, value in pairs(state) do adjusted[key] = value end
    if state.floating then
        local monitor = state.monitor_name and hl.get_monitor(state.monitor_name)
        if not monitor or not monitor.enabled then monitor = win.monitor end
        if not monitor or not monitor.enabled then monitor = hl.get_active_monitor() end
        assert(monitor and monitor.enabled, "monitor unavailable for placement restoration")
        local area = geometry.monitor_area(monitor)
        local bounds = geometry.monitor_area(monitor, true)
        assert(area and bounds, "monitor unavailable for placement restoration")
        local size = assert(geometry.resolve_size({w = state.width, h = state.height}, area, bounds))
        local position = geometry.resolve_position({
            x = state.x - state.monitor_x, y = state.y - state.monitor_y,
        }, area, size, bounds)
        adjusted.width, adjusted.height = size.width, size.height
        adjusted.x, adjusted.y = position.x, position.y
    end
    restore_pip(win, adjusted)
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

    if placement_states[id] then
        restore_placement(win, placement_states[id])
        placement_states[id] = nil
    end
    local actions = move_actions(win)
    if not (actions and win.at and win.at.x and win.at.y) then return end
    saved = snapshot(win)
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

local place_window = boot.safe_call(function(preset)
    local win = hl.get_active_window()
    if not (win and win.mapped and win.stable_id and win.address and win.at and win.size) then return end
    local monitor = window_monitor(win)
    local vars = require("hyprland.variables")
    local box, err = geometry.preset_box(preset, geometry.monitor_area(monitor, true),
        vars.defaultRule, geometry.monitor_area(monitor))
    assert(box, err)
    local id = win.stable_id
    if pip_states[id] then
        restore_pip(win, pip_states[id])
        pip_states[id] = nil
    end
    local saved = placement_states[id] or snapshot(win)
    placement_states[id] = saved
    local ok, failure = pcall(function()
        pip_fullscreen(win, 0, 0, saved.layout_aware)
        pip_dispatch(hl.dsp.window.float({window = addr(win), action = "on"}))
        pip_dispatch(hl.dsp.window.resize({
            window = addr(win), x = box.width, y = box.height, relative = false,
        }))
        pip_dispatch(hl.dsp.window.move({
            window = addr(win), x = box.x, y = box.y, relative = false,
        }))
    end)
    if not ok then
        if pcall(restore_placement, win, saved) then placement_states[id] = nil end
        error(failure)
    end
end, "windowPlacement")

local restore_window_placement = boot.safe_call(function()
    local win = hl.get_active_window()
    if not (win and win.mapped and win.stable_id and win.address) then return end
    local saved = placement_states[win.stable_id]
    if saved then
        restore_placement(win, saved)
        placement_states[win.stable_id] = nil
    end
end, "restoreWindowPlacement")

hl.on("window.close", function(win)
    if win and win.stable_id then
        pip_states[win.stable_id], placement_states[win.stable_id] = nil, nil
    end
end)

-- Lua state is discarded on reload: restore windows before losing their snapshots.
hl.on("config.unload", function()
    for id, state in pairs(placement_states) do
        local win = hl.get_window("address:" .. state.address)
        if win and win.mapped and win.stable_id == id then
            boot.safe_call(restore_placement, "Placement restore on unload")(win, state)
        end
    end
    for id, state in pairs(pip_states) do
        local win = hl.get_window("address:" .. state.address)
        if win and win.mapped and win.stable_id == id then
            boot.safe_call(restore_pip, "PiP restore on unload")(win, state)
        end
    end
end)

local toggle_floating = boot.safe_call(function()
    local win = hl.get_active_window()
    if not (win and win.address) then return end
    dispatch_geometry(hl.dsp.window.float({
        window = addr(win), action = win.floating and "off" or "on",
    }))
    if not win.floating then return end

    local vars = require("hyprland.variables")
    local spec = geometry.find_spec(vars, win.class)
    local monitor = window_monitor(win)
    local area = geometry.monitor_area(monitor)
    local bounds = geometry.monitor_area(monitor, true)
    if not (area and bounds) then return end
    local size, err = geometry.resolve_size(spec, area, bounds)
    assert(size, err)
    dispatch_geometry(hl.dsp.window.resize({
        window = addr(win), x = size.width, y = size.height, relative = false,
    }))
    local position = geometry.resolve_position(spec, area, size, bounds)
    if position then
        dispatch_geometry(hl.dsp.window.move({
            window = addr(win), x = position.x, y = position.y, relative = false,
        }))
    end
end, "kbToggleWindowFloating")

-- Change only the active scrolling workspace, including an open special workspace.
local set_scroll_direction = boot.safe_call(function(direction)
    assert(direction == "right" or direction == "down", "unsupported scroll direction")
    local workspace = hl.get_active_special_workspace() or hl.get_active_workspace()
    if not workspace or workspace.tiled_layout ~= "scrolling" then return end

    local selector = workspace_selector(workspace)
    if not selector then return end
    hl.workspace_rule({
        workspace = selector,
        layout_opts = { direction = direction },
    })
end, "setScrollDirection")

local function cycle_workspace_layout(layouts)
    return boot.safe_call(function()
        local workspace = hl.get_active_special_workspace() or hl.get_active_workspace()
        local selector = workspace_selector(workspace)
        if not selector then return end

        local next_layout = "dwindle"

        for i = 1, #layouts do
            if layouts[i] == workspace.tiled_layout then
                local next_layout_idx = (i % #layouts) + 1
                next_layout = layouts[next_layout_idx]
                break
            end
        end

        hl.workspace_rule({ workspace = selector, layout = next_layout })
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
    place_window          = place_window,
    restore_window_placement = restore_window_placement,
    toggle_floating       = toggle_floating,
    cycle_all_layouts     = cycle_all_layouts,
    toggle_scroll_layout  = toggle_scroll_layout,
    set_scroll_direction  = set_scroll_direction,
    noctalia              = noctalia,
}
