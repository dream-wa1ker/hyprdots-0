-- Binding registration and fallback for Hyprland 0.57.
-- Dispatcher construction belongs in build_action; callbacks remain in action.
local M = {}
local defaults = {}

function M.capture_defaults(keys)
    defaults = {}
    for name, key in pairs(type(keys) == "table" and keys or {}) do
        defaults[name] = key
    end
end

function M.default_key(name)
    return defaults[name]
end

function M.workspace_key(prefix, index)
    if type(prefix) ~= "string" then return nil end
    return prefix .. " + " .. index
end

local function normalize(key)
    if type(key) ~= "string" then return nil, "key must be a string" end
    local parts, seen = {}, {}
    for part in (key .. "+"):gmatch("(.-)%+") do
        local token = part:match("^%s*(.-)%s*$"):lower()
        if token == "" then return nil, "key contains an empty component" end
        if seen[token] then return nil, "key contains a repeated component" end
        seen[token] = true
        parts[#parts + 1] = token
    end
    table.sort(parts)
    return table.concat(parts, "+")
end

local boolean_options = {
    repeating = true, locked = true, release = true,
    non_consuming = true, auto_consuming = true, transparent = true,
    ignore_mods = true, dont_inhibit = true, long_press = true,
    submap_universal = true, mouse = true, click = true, drag = true,
    allow_input_capture = true,
}

local function validate(entry)
    if type(entry) ~= "table" then return "entry must be a table" end
    if entry.action ~= nil and entry.build_action ~= nil then
        return "use either action or build_action"
    end
    if entry.build_action ~= nil and type(entry.build_action) ~= "function" then
        return "build_action must be a function"
    end
    if entry.action == nil and entry.build_action == nil then
        return "entry needs action or build_action"
    end
    local opts = entry.options
    if opts == nil then return nil end
    if type(opts) ~= "table" then return "options must be a table" end
    for key, value in pairs(opts) do
        if boolean_options[key] and type(value) ~= "boolean" then
            return key .. " must be a boolean"
        end
        if (key == "description" or key == "desc") and type(value) ~= "string" then
            return key .. " must be a string"
        end
    end
    if opts.click and opts.drag then return "click and drag are exclusive" end
    if opts.repeating and (opts.release or opts.long_press or opts.click or opts.drag) then
        return "repeating conflicts with release/long_press/click/drag"
    end
    if opts.mouse and (opts.repeating or opts.release or opts.locked or opts.click or opts.drag) then
        return "mouse conflicts with repeating/release/locked/click/drag"
    end
    if opts.device ~= nil then
        local device = opts.device
        if type(device) ~= "table" then return "device must be a table" end
        if device.inclusive ~= nil and type(device.inclusive) ~= "boolean" then
            return "device.inclusive must be a boolean"
        end
        if device.list ~= nil then
            if type(device.list) ~= "table" then return "device.list must be a table" end
            for _, name in pairs(device.list) do
                if type(name) ~= "string" then return "device.list needs strings" end
            end
        end
    end
end

function M.register(entries, custom_loader)
    local problems, occupied = {}, {}
    local result = { registered = 0, problems = problems }
    local function report(message)
        problems[#problems + 1] = message
        print("[Hyprland config] keybinds: " .. message)
    end

    -- Sorted integer indices also allow later entries to survive a hole in a list.
    local function ordered(list, label)
        if type(list) ~= "table" then
            report(label .. " must return a table")
            return {}
        end
        local indices, items = {}, {}
        for index in pairs(list) do
            if type(index) == "number" and index >= 1 and index % 1 == 0 then
                indices[#indices + 1] = index
            else
                report(label .. ": ignored non-list entry " .. tostring(index))
            end
        end
        table.sort(indices)
        for _, index in ipairs(indices) do
            items[#items + 1] = { entry = list[index], label = label .. " #" .. index }
        end
        return items
    end

    local custom = {}
    if custom_loader then
        local ok, value = pcall(custom_loader)
        if not ok then
            if not tostring(value):match("^module 'custom%.keybinds' not found") then
                report("custom.keybinds failed to load: " .. tostring(value))
            end
        elseif value ~= nil and value ~= true then
            custom = value -- true is the normal result of an empty Lua module.
        end
    end

    local custom_by_key, custom_order = {}, {}
    for _, item in ipairs(ordered(custom, "custom")) do
        local entry = item.entry
        local err = validate(entry)
        local key, key_err = normalize(type(entry) == "table" and entry.key)
        if err or not key then
            report(item.label .. ": " .. (err or key_err))
        elseif custom_by_key[key] then
            report("duplicate custom keybinding ignored: " .. entry.key)
        else
            item.key = key
            custom_by_key[key] = item
            custom_order[#custom_order + 1] = item
        end
    end

    -- Cache construction so retrying an original shortcut cannot rebuild an action.
    local built = {}
    local function try_bind(entry, key, label)
        local normalized, key_err = normalize(key)
        if not normalized then
            report(label .. ": " .. key_err)
            return false
        end
        if occupied[normalized] then
            report(label .. ": shortcut already registered: " .. key)
            return false
        end
        local err = validate(entry)
        if err then report(label .. ": " .. err); return false end
        local action = built[entry]
        if not action then
            local ok, value = true, entry.action
            if entry.build_action then ok, value = pcall(entry.build_action) end
            local kind = type(value)
            action = { ok = ok and (kind == "function" or kind == "userdata" or kind == "table"), value = value }
            built[entry] = action
        end
        if not action.ok then
            report(label .. ": invalid action or construction failure: " .. tostring(action.value))
            return false
        end
        local ok, handle = pcall(hl.bind, key, action.value, entry.options or {})
        if not ok or handle == nil or handle == false then
            report(label .. ": registration failed: " .. (ok and "no binding returned" or tostring(handle)))
            return false
        end
        occupied[normalized] = true
        result.registered = result.registered + 1
        return true
    end

    local seen_defaults, handled_custom, pending_fallbacks = {}, {}, {}
    for _, item in ipairs(ordered(entries, "default")) do
        local entry = item.entry
        if type(entry) ~= "table" then
            report(item.label .. ": entry must be a table")
        else
            local key = normalize(entry.key)
            local fallback = normalize(entry.fallback_key)
            local identity = key or fallback
            if identity and seen_defaults[identity] then
                report(item.label .. ": duplicate default keybinding ignored")
            else
                if identity then seen_defaults[identity] = true end
                local replacement = identity and custom_by_key[identity]
                local bound = false
                if replacement then
                    handled_custom[identity] = true
                    bound = try_bind(replacement.entry, replacement.entry.key, replacement.label)
                    if not bound then report(replacement.label .. ": using default fallback") end
                end
                if not bound then
                    bound = try_bind(entry, entry.key, item.label)
                    if not bound and fallback and fallback ~= key then
                        pending_fallbacks[#pending_fallbacks + 1] = item
                    end
                end
            end
        end
    end

    for _, item in ipairs(custom_order) do
        if not handled_custom[item.key] then
            try_bind(item.entry, item.entry.key, item.label)
        end
    end

    -- Valid configured shortcuts take priority over recovery to an original key.
    for _, item in ipairs(pending_fallbacks) do
        try_bind(item.entry, item.entry.fallback_key, item.label .. " original shortcut")
    end

    if #problems > 0 then
        local ok, err = pcall(function()
            hl.notification.create({
                text = ("Keybinds: %d problem(s). Run hyprctl rollinglog for details."):format(#problems),
                timeout = 8000, icon = "warning",
            })
        end)
        if not ok then print("[Hyprland config] keybind notification failed: " .. tostring(err)) end
    end
    return result
end

return M
