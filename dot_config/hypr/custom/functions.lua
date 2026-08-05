-- ~/.config/hypr/custom/functions.lua

-- Turn an HL.Window into the address-selector string dispatchers expect.
-- (hl.dsp.* window fields want a selector string, not the window table itself.)
local function addr(win)
    return win and win.address and ("address:" .. win.address) or nil
end

-- Workspace-group-aware focus/move. range="group" keeps you inside the
-- current group of 10; range="" jumps to the absolute workspace number i.
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

-- Resize target as a percentage of the active monitor's resolution.
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

-- Relative resize of the focused window by percentage of its own size.
local function resize_active_window(x, y)
    local win = hl.get_active_window()
    if win and win.size and win.size.x and win.size.y then
        local w = win.size.x * (x / 100)
        local h = win.size.y * (y / 100)
        return { x = w, y = h, relative = true }
    end
    -- no active window / no size data: return nil rather than a fake fallback,
    -- callers already check before dispatching
end

-- Match a window by title pattern, run arbitrary dispatches on it, then
-- resize it to a screen percentage and lock its aspect ratio.
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

-- Used for PIP: shrink+dock a window to the bottom-right corner, sized to
-- 1/4 of screen height while keeping its aspect ratio.
local function move_actions(win)
    local screen = hl.get_active_monitor()

    if screen and screen.width and screen.height and win and win.size then
        local monitor_height = screen.height / screen.scale
        local monitor_width  = screen.width / screen.scale

        local scale_factor  = (monitor_height / 4) / win.size.y

        local target_width  = win.size.x * scale_factor
        local target_height = win.size.y * scale_factor

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

-- Look up a per-app float size/position from variables.floatRules, falling
-- back to defaultRule, merged with any extra spawn-rule overrides (float=true,
-- pseudo=true, etc). NOTE: needs vars.floatRules / vars.defaultRule — see
-- step 2, not usable until then.
local function floatSpawnRule(appKey, extra)
    local vars = require("custom.variables")
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

return {
    addr                  = addr,
    resizer               = resizer,
    resize_by_screen      = resize_by_screen,
    resize_active_window  = resize_active_window,
    wsaction              = wsaction,
    move_actions           = move_actions,
    floatSpawnRule        = floatSpawnRule,
}
