-- ~/.config/hypr/hyprland/functions.lua

local boot = require("core.bootstrap")

local function addr(win)
    return win and win.address and ("address:" .. win.address) or nil
end

local function wsaction(action, range, i)
    return function()
        local activews = hl.get_active_workspace()
        if activews then
            local id = activews.id
            local s  = (i - 1) * 10 + (id % 10)
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
    local screen = hl.get_active_monitor()

    if screen and screen.width and screen.height and win and win.size then
        local monitor_height = screen.height / screen.scale
        local monitor_width  = screen.width / screen.scale

        local scale_factor   = (monitor_height / 4) / win.size.y

        local target_width   = win.size.x * scale_factor
        local target_height  = win.size.y * scale_factor

        local x_resize = math.floor(math.max(200, target_width))
        local y_resize = math.floor(math.max(150, target_height))

        local offset = math.min(monitor_width, monitor_height) * 0.03

        local move_x = math.floor(screen.x + monitor_width - x_resize - offset)
        local move_y = math.floor(screen.y + monitor_height - y_resize - offset)

        return {
            hl.dsp.window.resize({ x = x_resize, y = y_resize, window = addr(win) }),
            hl.dsp.window.move({ x = move_x, y = move_y, relative = false, window = addr(win) }),
        }
    end
end

local function floatSpawnRule(appKey, extra)
    local vars = require("hyprland.variables")
    local r = vars.floatRules[appKey] or vars.defaultRule
    local eff = { size = r.w .. " " .. r.h }

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

local toggle_pip = boot.safe_call(function()
    local a = hl.get_active_window()
    if a then
        local pip = move_actions(a) or {}
        if not a.floating then table.insert(pip, 1, hl.dsp.window.float()) end
        table.insert(pip, hl.dsp.window.pin({ action = "on", window = addr(a) }))

        for _, x in ipairs(pip) do
            hl.dispatch(x)
        end
    end
end, "kbWindowPip")

local toggle_floating = boot.safe_call(function()
    local vars = require("hyprland.variables")
    hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
    local w = hl.get_active_window()
    if w and w.floating then
        local class = w.class and w.class:lower() or ""
        local rule = vars.floatRules[class] or vars.defaultRule

        hl.dispatch(hl.dsp.window.resize({ exact = true, x = rule.w, y = rule.h }))

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
}
