-- Geometry calculations and specification merging for Hyprland 0.57.
-- No compositor actions, event subscriptions, or filesystem access.
local M = {}

local function finite(value)
    return type(value) == "number" and value == value
        and value ~= math.huge and value ~= -math.huge
end

local function positive(value)
    return finite(value) and value > 0
end

function M.validate_spec(spec)
    if type(spec) ~= "table" then return nil, "geometry must be a table" end
    local pixels = spec.w ~= nil or spec.h ~= nil
    local fractions = spec.wp ~= nil or spec.hp ~= nil
    if pixels == fractions then return nil, "choose w/h or wp/hp" end
    if pixels and not (positive(spec.w) and positive(spec.h)) then
        return nil, "w and h must be positive finite numbers"
    end
    if fractions and not (positive(spec.wp) and spec.wp <= 1
        and positive(spec.hp) and spec.hp <= 1) then
        return nil, "wp and hp must be greater than 0 and at most 1"
    end
    if (spec.x ~= nil or spec.y ~= nil)
        and not (finite(spec.x) and finite(spec.y)) then
        return nil, "x and y must both be finite numbers"
    end
    for _, key in ipairs({ "auto_float", "center" }) do
        if spec[key] ~= nil and type(spec[key]) ~= "boolean" then
            return nil, key .. " must be a boolean"
        end
    end
    if spec.classes ~= nil then
        if type(spec.classes) ~= "table" or #spec.classes == 0 then
            return nil, "classes must be a nonempty list"
        end
        for index = 1, #spec.classes do
            if type(spec.classes[index]) ~= "string" then return nil, "classes cannot contain holes" end
        end
        for index, class in pairs(spec.classes) do
            if type(index) ~= "number" or index % 1 ~= 0 or index < 1
                or index > #spec.classes or type(class) ~= "string" or class == "" then
                return nil, "classes must be a dense list of nonempty strings"
            end
        end
    end
    return true
end

-- Keep the old table format, but remove the other size mode on explicit changes.
function M.merge_spec(base, patch)
    if type(patch) ~= "table" then return nil, "override must be a table" end
    local candidate = {}
    for key, value in pairs(type(base) == "table" and base or {}) do
        candidate[key] = value
    end
    local pixels = patch.w ~= nil or patch.h ~= nil
    local fractions = patch.wp ~= nil or patch.hp ~= nil
    if pixels and fractions then return nil, "override mixes w/h and wp/hp" end
    if pixels then candidate.wp, candidate.hp = nil, nil end
    if fractions then candidate.w, candidate.h = nil, nil end
    if patch.center == true and patch.x == nil and patch.y == nil then
        candidate.x, candidate.y = nil, nil
    end
    for key, value in pairs(patch) do candidate[key] = value end
    if patch.x ~= nil or patch.y ~= nil then candidate.center = false end
    local ok, err = M.validate_spec(candidate)
    if not ok then return nil, err end
    return candidate
end

-- Preserve ordinary deep merging; handle geometry records as mutually exclusive modes.
function M.merge_overrides(vars, overrides, deep_merge)
    local function warn(label, err)
        print("[Hyprland config] geometry: " .. label .. ": " .. err)
    end
    if type(overrides) ~= "table" then
        warn("variables", "override must be a table")
        return vars
    end
    local ordinary = {}
    for key, value in pairs(overrides) do
        if key ~= "floatRules" and key ~= "defaultRule" then ordinary[key] = value end
    end
    deep_merge(vars, ordinary)
    if overrides.defaultRule ~= nil then
        local spec, err = M.merge_spec(vars.defaultRule, overrides.defaultRule)
        if spec then vars.defaultRule = spec else warn("defaultRule", err) end
    end
    if overrides.floatRules ~= nil then
        if type(overrides.floatRules) ~= "table" then
            warn("floatRules", "override must be a table")
        else
            for class, patch in pairs(overrides.floatRules) do
                if type(class) ~= "string" or class == "" then
                    warn("floatRules", "class keys must be nonempty strings")
                else
                    local spec, err = M.merge_spec(vars.floatRules[class], patch)
                    if spec then vars.floatRules[class] = spec
                    else warn("floatRules." .. class, err) end
                end
            end
        end
    end
    return vars
end

-- mode.width/height are logical, already accounting for rotation and scale.
-- Fallback supports monitor snapshots that do not expose mode.
function M.monitor_area(monitor, usable)
    if not monitor then return nil end
    local mode = monitor.mode
    local width, height
    if type(mode) == "table" and positive(mode.width) and positive(mode.height) then
        width, height = mode.width, mode.height
    elseif positive(monitor.width) and positive(monitor.height) then
        local scale = positive(monitor.scale) and monitor.scale or 1
        width, height = monitor.width / scale, monitor.height / scale
        local transform = finite(monitor.transform) and monitor.transform or 0
        if transform % 2 == 1 then width, height = height, width end
    else return nil end
    local x = finite(monitor.x) and monitor.x or 0
    local y = finite(monitor.y) and monitor.y or 0
    if usable then
        local reserved = monitor.reserved or {}
        local function edge(key)
            return finite(reserved[key]) and math.max(0, reserved[key]) or 0
        end
        local left, top = edge("left"), edge("top")
        x, y = x + left, y + top
        width = width - left - edge("right")
        height = height - top - edge("bottom")
    end
    if width < 1 or height < 1 then return nil end
    return { x = x, y = y, width = width, height = height }
end

-- Percentages use the full logical monitor; bounds optionally limit floating sizes.
function M.resolve_size(spec, area, bounds)
    local ok, err = M.validate_spec(spec)
    if not ok then return nil, err end
    if not area then return nil, "monitor area unavailable" end
    local width = spec.w or area.width * spec.wp
    local height = spec.h or area.height * spec.hp
    if bounds then
        width, height = math.min(width, bounds.width), math.min(height, bounds.height)
    end
    return { width = math.max(1, math.floor(width)), height = math.max(1, math.floor(height)) }
end

-- Explicit offsets are monitor-local like native rules. Centering uses usable bounds.
function M.resolve_position(spec, area, size, bounds)
    if type(spec) ~= "table" or not (area and size) then return nil end
    bounds = bounds or area
    local x, y
    if spec.x ~= nil and spec.y ~= nil then
        x, y = area.x + spec.x, area.y + spec.y
    elseif spec.center ~= false then
        x = bounds.x + (bounds.width - size.width) / 2
        y = bounds.y + (bounds.height - size.height) / 2
    else return nil end
    x = math.max(bounds.x, math.min(x, bounds.x + math.max(0, bounds.width - size.width)))
    y = math.max(bounds.y, math.min(y, bounds.y + math.max(0, bounds.height - size.height)))
    return { x = math.max(bounds.x, math.floor(x)), y = math.max(bounds.y, math.floor(y)) }
end

-- Uniform scaling for PiP, preserving the existing 25%-height / 40%-width policy.
function M.pip_box(area, size)
    if not (area and size and positive(size.x) and positive(size.y)) then return nil end
    local factor = math.min(area.height * 0.25 / size.y, area.width * 0.40 / size.x)
    local width = math.max(1, math.floor(size.x * factor))
    local height = math.max(1, math.floor(size.y * factor))
    local margin = math.floor(math.min(area.width, area.height) * 0.03)
    return {
        x = math.floor(area.x + area.width - width - margin),
        y = math.floor(area.y + area.height - height - margin),
        width = width, height = height,
    }
end

function M.find_spec(vars, key)
    local rules = vars.floatRules or {}
    local class = type(key) == "string" and key or ""
    local commands = vars.floatCommandClasses or {}
    class = commands[class] or commands[class:lower()] or class
    local spec = rules[class:lower()]
    if not spec then
        for name, candidate in pairs(rules) do
            if type(name) == "string" and name:lower() == class:lower() then
                spec = candidate; break
            end
            for _, alias in ipairs(candidate.classes or {}) do
                if alias:lower() == class:lower() then spec = candidate; break end
            end
            if spec then break end
        end
    end
    return spec or vars.defaultRule
end

function M.rule_effects(spec)
    local ok, err = M.validate_spec(spec)
    if not ok then return nil, err end
    local effects = {}
    if spec.wp then
        effects.size = {
            "(monitor_w*" .. tostring(spec.wp) .. ")",
            "(monitor_h*" .. tostring(spec.hp) .. ")",
        }
    else effects.size = { math.max(1, math.floor(spec.w)), math.max(1, math.floor(spec.h)) } end
    if spec.x ~= nil then
        effects.move = { spec.x, spec.y } -- native rule coordinates are monitor-local
        effects.center = false
    else effects.center = spec.center ~= false end
    return effects
end

function M.class_pattern(key, spec)
    local function escape(class)
        return (class:gsub(".", function(char)
            if ("\\.^$|?*+()[]{}"):find(char, 1, true) then return "\\" .. char end
            return char
        end))
    end
    local classes = {}
    for _, class in ipairs(spec.classes or { key }) do classes[#classes + 1] = escape(class) end
    return "^(" .. table.concat(classes, "|") .. ")$"
end

-- Fractions describe shared edges, so odd-sized halves meet without gaps.
local presets = {
    left = {0, 0, .5, 1}, right = {.5, 0, 1, 1},
    top = {0, 0, 1, .5}, bottom = {0, .5, 1, 1},
    top_left = {0, 0, .5, .5}, top_right = {.5, 0, 1, .5},
    bottom_left = {0, .5, .5, 1}, bottom_right = {.5, .5, 1, 1},
    fill = {0, 0, 1, 1},
}

function M.preset_box(name, area, center_spec, full_area)
    if not (area and finite(area.x) and finite(area.y)
        and positive(area.width) and area.width >= 1
        and positive(area.height) and area.height >= 1) then
        return nil, "usable monitor area unavailable"
    end
    if name == "center" then
        local size, err = M.resolve_size(center_spec or {wp = .55, hp = .6}, full_area or area, area)
        if not size then return nil, err end
        local position = M.resolve_position({center = true}, full_area or area, size, area)
        return {x = position.x, y = position.y, width = size.width, height = size.height}
    end
    local edges = presets[name]
    if not edges then return nil, "unknown placement preset: " .. tostring(name) end
    local left = math.min(math.floor(area.width * edges[1]), math.floor(area.width) - 1)
    local top = math.min(math.floor(area.height * edges[2]), math.floor(area.height) - 1)
    return {
        x = area.x + left, y = area.y + top,
        width = math.max(1, math.floor(area.width * edges[3]) - left),
        height = math.max(1, math.floor(area.height * edges[4]) - top),
    }
end

return M
