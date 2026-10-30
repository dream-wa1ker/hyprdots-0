-- Binding registration and fallback for Hyprland 0.57.
-- Dispatcher construction belongs in build_action; callbacks remain in action.
local M = {}
local defaults, default_records = {}, {}

local function copy(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for key, item in pairs(value) do result[key] = copy(item) end
    return result
end

local policies, setting_problems = {}, {}

function M.capture_defaults(keys)
    defaults, default_records = {}, {}
    for name, setting in pairs(type(keys) == "table" and keys or {}) do
        default_records[name] = copy(setting)
        if type(setting) == "table" then defaults[name] = setting.key
        else defaults[name] = setting end
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

function M.register(entries, custom_loader, options)
    local problems, occupied = {}, {}
    local result = { registered = 0, problems = problems, handles = {} }
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
            local entry = list[index]
            local identity = type(entry) == "table" and entry.id
            items[#items + 1] = { entry = entry,
                label = identity and (label .. " action '" .. identity .. "'") or (label .. " #" .. index) }
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
        if entry.candidates then
            for index, candidate in ipairs(entry.candidates) do
                if try_bind(candidate, key, label .. " candidate " .. index) then return true end
            end
            return false
        end
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
        if entry.id then result.handles[entry.id] = handle end
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

    if #problems > 0 and not (options and options.quiet) then
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

-- High-level action catalog adapter. The registration/fallback engine above
-- remains usable with legacy arrays independently of this interface.
local prefix_ids = {
    goToWorkspacePrefix = true, moveWindowToWorkspacePrefix = true,
    goToWorkspaceGroupPrefix = true, moveWindowToWorkspaceGroupPrefix = true,
}

local function patch_options(base, patch)
    local result = copy(base or {})
    for key, value in pairs(patch or {}) do result[key] = copy(value) end
    return result
end

local function sorted_keys(map)
    local keys = {}
    for key in pairs(map) do if type(key) == "string" then keys[#keys + 1] = key end end
    table.sort(keys)
    return keys
end

local function same(left, right)
    if type(left) ~= "table" or type(right) ~= "table" then return left == right end
    for key, value in pairs(left) do if not same(value, right[key]) then return false end end
    for key in pairs(right) do if left[key] == nil then return false end end
    return true
end

-- Normalize before custom files load, preserving their kb.<id> string interface.
function M.resolve_settings(vars)
    policies, setting_problems = {}, {}
    local function report(id, err)
        local message = "action '" .. tostring(id) .. "': " .. err .. "; using default settings"
        setting_problems[#setting_problems + 1] = message
        print("[Hyprland config] keybinds: " .. message)
    end
    local raw = vars.keybinds
    if type(raw) ~= "table" then report("keybinds", "must be a table"); raw = {} end
    local all, resolved = copy(default_records), {}
    for id, value in pairs(raw) do
        if type(id) == "string" and id ~= "" then all[id] = value
        else report(id, "IDs must be nonempty strings") end
    end
    for _, id in ipairs(sorted_keys(all)) do
        local value, spec, err = all[id], {}, nil
        if type(value) == "string" then spec.key = value
        elseif type(value) ~= "table" then err = "expected a shortcut string or settings record"
        else
            spec = copy(value)
            for field in pairs(spec) do
                if field ~= "key" and field ~= "enabled" and field ~= "description" and field ~= "options" then
                    err = "unknown settings field '" .. tostring(field) .. "'"
                elseif prefix_ids[id] and field ~= "key" and field ~= "enabled" then
                    err = "workspace prefixes support only key and enabled"
                end
            end
            if spec.enabled ~= nil and type(spec.enabled) ~= "boolean" then err = "enabled must be a boolean" end
            if spec.description ~= nil and type(spec.description) ~= "string" then err = "description must be a string" end
            if spec.options ~= nil then
                err = err or validate({action = function() end, options = spec.options})
            end
        end
        if not err and spec.key ~= nil then
            local _, key_err = normalize(spec.key)
            err = key_err
        end
        if err then
            report(id, err)
            local original = default_records[id]
            spec = type(original) == "table" and copy(original) or {key = original}
        end
        spec.key = spec.key or defaults[id]
        spec.explicit = not same(value, default_records[id])
        policies[id], resolved[id] = spec, spec.key
    end
    -- Generated IDs also expose strings before custom functions/bindings load.
    local families = {
        ["workspace.focus"] = "goToWorkspacePrefix",
        ["workspace.move"] = "moveWindowToWorkspacePrefix",
        ["workspace.groupFocus"] = "goToWorkspaceGroupPrefix",
        ["workspace.groupMove"] = "moveWindowToWorkspaceGroupPrefix",
    }
    for family, prefix in pairs(families) do
        for index = 1, 10 do
            local id = family .. "." .. index
            local policy = policies[id]
            resolved[id] = resolved[id] or M.workspace_key(resolved[prefix], index % 10)
            if policy then policy.key = resolved[id] end
        end
    end
    vars.keybinds = resolved
    return resolved
end

-- Definitions contain behavior; policies contain keys, flags, and enabled state.
function M.register_catalog(definitions, custom_loader)
    local problems, scopes, scope_order = copy(setting_problems), {default = {}}, {"default"}
    local result = {registered = 0, problems = problems, handles = {}}
    local function report(message)
        problems[#problems + 1] = message
        print("[Hyprland config] keybinds: " .. message)
    end
    local custom = {}
    if custom_loader then
        local ok, value = pcall(custom_loader)
        if not ok then
            if not tostring(value):match("^module 'custom%.keybinds' not found") then
                report("custom.keybinds failed to load: " .. tostring(value))
            end
        elseif value ~= nil and value ~= true then
            if type(value) == "table" then custom = value else report("custom.keybinds must return a table") end
        end
    end
    local named, named_order, legacy, indices = {}, {}, {}, {}
    local function add_named(id, entry)
        if type(id) ~= "string" or id == "" then report("custom action needs a nonempty ID")
        elseif named[id] ~= nil then report("duplicate custom action '" .. id .. "' ignored")
        elseif type(entry) == "table" and entry.id ~= nil and entry.id ~= id then
            report("custom action '" .. id .. "' has a mismatched id field")
        else named[id] = entry; named_order[#named_order + 1] = id end
    end
    for key in pairs(custom) do
        if type(key) == "number" and key >= 1 and key % 1 == 0 then indices[#indices + 1] = key
        elseif type(key) ~= "string" then report("ignored invalid custom list index") end
    end
    table.sort(indices)
    for _, index in ipairs(indices) do
        local entry = custom[index]
        if type(entry) == "table" and entry.id ~= nil then add_named(entry.id, entry)
        else legacy[#legacy + 1] = entry end
    end
    for _, id in ipairs(sorted_keys(custom)) do add_named(id, custom[id]) end

    local known, ordered = {}, {}
    for _, definition in ipairs(definitions) do
        local id = definition.id
        if type(id) ~= "string" or id == "" then report("catalog action needs an ID")
        elseif known[id] then report("duplicate catalog action '" .. id .. "' ignored")
        else known[id] = definition; ordered[#ordered + 1] = definition end
    end
    for _, id in ipairs(named_order) do
        if not known[id] then
            local definition = {id = id}
            known[id] = definition; ordered[#ordered + 1] = definition
        end
    end
    local function candidate(definition, patch, policy)
        local entry = copy(definition)
        entry.options = copy(entry.options or {})
        if entry.description ~= nil then entry.options.description = entry.description end
        if patch ~= nil then
            if type(patch) ~= "table" then return nil, "custom definition must be a table" end
            for field in pairs(patch) do
                if field ~= "id" and field ~= "description" and field ~= "options"
                    and field ~= "action" and field ~= "build_action" then
                    return nil, "unknown custom definition field '" .. tostring(field) .. "'; put keys/settings in variables.lua"
                end
            end
            if patch.action ~= nil and patch.build_action ~= nil then return nil, "use either action or build_action" end
            if patch.options ~= nil and type(patch.options) ~= "table" then return nil, "options must be a table" end
            if patch.action ~= nil then entry.build_action = nil end
            if patch.build_action ~= nil then entry.action = nil end
            for field, value in pairs(patch) do
                if field ~= "options" then entry[field] = value end
            end
            entry.options = patch_options(entry.options, patch.options)
            if patch.description ~= nil then entry.options.description = patch.description end
        end
        local base_options = copy(entry.options)
        entry.options = patch_options(entry.options, policy.options)
        if policy.description ~= nil then entry.options.description = policy.description end
        local err = validate(entry)
        if err and (policy.options or policy.description) then
            entry.options = base_options
            local base_err = validate(entry)
            if not base_err then
                report("action '" .. entry.id .. "': invalid combined settings (" .. err .. "); using definition options")
                err = nil
            end
        end
        if err then return nil, err end
        return entry
    end
    for _, definition in ipairs(ordered) do
        local id = definition.id
        local policy = definition.internal and {} or (policies[id] or {})
        local parent = definition.parent and policies[definition.parent]
        if definition.internal and (named[id] ~= nil or policies[id]) then report("action '" .. id .. "' is an internal cancellation binding") end
        if policy.enabled ~= false and not (parent and parent.enabled == false) then
            local key = policy.key or definition.key or defaults[id]
            local fallback = definition.fallback_key or defaults[id] or key
            local base, base_err = candidate(definition, nil, policy)
            local preferred, custom_err
            if named[id] ~= nil and not definition.internal then preferred, custom_err = candidate(definition, named[id], policy) end
            if custom_err then report("custom action '" .. id .. "': " .. custom_err .. "; using built-in definition") end
            local candidates = {}
            if preferred then candidates[#candidates + 1] = preferred end
            if base then candidates[#candidates + 1] = base end
            if #candidates == 0 then report("action '" .. id .. "': " .. (base_err or "no valid definition"))
            else
                local scope = definition.submap or "default"
                if not scopes[scope] then scopes[scope] = {}; scope_order[#scope_order + 1] = scope end
                scopes[scope][#scopes[scope] + 1] = {id = id, key = key, fallback_key = fallback, candidates = candidates}
            end
        end
    end
    for id, policy in pairs(policies) do
        if policy.explicit and not known[id] and not prefix_ids[id] then report("settings reference unknown action '" .. id .. "'") end
    end
    for _, scope in ipairs(scope_order) do
        local function register_scope()
            local registered = M.register(scopes[scope], scope == "default" and function() return legacy end or nil, {quiet = true})
            result.registered = result.registered + registered.registered
            for _, problem in ipairs(registered.problems) do problems[#problems + 1] = problem end
            for id, handle in pairs(registered.handles) do result.handles[id] = handle end
        end
        if scope == "default" then register_scope() else hl.define_submap(scope, register_scope) end
    end
    if #problems > 0 then
        pcall(hl.notification.create, {text = ("Keybinds: %d problem(s). Run hyprctl rollinglog for details."):format(#problems),
            timeout = 8000, icon = "warning"})
    end
    return result
end

return M
