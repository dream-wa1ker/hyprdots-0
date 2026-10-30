-- Resolve complete binding records, custom patches, and native registration.
-- No dependency on variables.lua and no mutable state retained between registrations.
local M = {}

local function copy(value)
    if type(value) ~= "table" then return value end
    local out = {}; for key, item in pairs(value) do out[key] = copy(item) end
    return out
end

local function same(a, b)
    if type(a) ~= "table" or type(b) ~= "table" then return a == b end
    for key, value in pairs(a) do if not same(value, b[key]) then return false end end
    for key in pairs(b) do if a[key] == nil then return false end end
    return true
end

local function normalize(key)
    if type(key) ~= "string" then return nil, "key must be a string" end
    local parts, seen = {}, {}
    for part in (key .. "+"):gmatch("(.-)%+") do
        local token = part:match("^%s*(.-)%s*$"):lower()
        if token == "" then return nil, "key contains an empty component" end
        if seen[token] then return nil, "key contains a repeated component" end
        seen[token] = true; parts[#parts + 1] = token
    end
    table.sort(parts)
    return table.concat(parts, "+")
end

local function scope_name(scope)
    if scope == nil or scope == "" or scope == "default" or scope == "reset" then return "default" end
    if type(scope) ~= "string" or not scope:match("%S") then return nil, "submap must be a nonempty string" end
    return scope
end

local booleans = {
    repeating = true, locked = true, release = true, non_consuming = true,
    auto_consuming = true, transparent = true, ignore_mods = true, dont_inhibit = true,
    long_press = true, submap_universal = true, mouse = true, click = true, drag = true,
    allow_input_capture = true,
}

local function string_list(list)
    if type(list) ~= "table" then return "must be a list" end
    local count = 0
    for key, value in pairs(list) do
        if type(key) ~= "number" or key < 1 or key % 1 ~= 0 or type(value) ~= "string" or value == "" then
            return "must be a dense list of nonempty strings"
        end
        count = count + 1
    end
    for index = 1, count do if list[index] == nil then return "cannot contain holes" end end
end

local function validate_options(opts)
    if opts == nil then return nil end
    if type(opts) ~= "table" then return "options must be a table" end
    for key, value in pairs(opts) do
        if booleans[key] then
            if type(value) ~= "boolean" then return "options." .. key .. " must be a boolean" end
        elseif key == "description" or key == "desc" then
            if type(value) ~= "string" then return "options." .. key .. " must be a string" end
        elseif key == "device" then
            if type(value) ~= "table" then return "options.device must be a table" end
            for field, item in pairs(value) do
                if field == "inclusive" then
                    if type(item) ~= "boolean" then return "device.inclusive must be a boolean" end
                elseif field == "list" then
                    local err = string_list(item); if err then return "device.list " .. err end
                else return "unknown device option '" .. tostring(field) .. "'" end
            end
        else return "unknown binding option '" .. tostring(key) .. "'" end
    end
    if opts.click and opts.drag then return "click and drag are exclusive" end
    if opts.repeating and (opts.release or opts.long_press or opts.click or opts.drag) then
        return "repeating conflicts with release/long_press/click/drag"
    end
    if opts.mouse and (opts.repeating or opts.release or opts.locked or opts.click or opts.drag) then
        return "mouse conflicts with repeating/release/locked/click/drag"
    end
end

local public_fields = {id = true, key = true, enabled = true, description = true,
    action = true, build_action = true, options = true, submap = true}
local private_fields = {internal = true, parent = true, suffix = true, prefix = true}

local function validate(entry, partial, custom)
    if type(entry) ~= "table" then return "binding must be a table" end
    for field in pairs(entry) do
        if not public_fields[field] and (custom or not private_fields[field]) then
            return "unknown binding field '" .. tostring(field) .. "'"
        end
    end
    if entry.id ~= nil and (type(entry.id) ~= "string" or entry.id == "") then return "id must be a nonempty string" end
    if entry.key ~= nil or not partial then
        local _, err = normalize(entry.key); if err then return err end
    end
    if entry.enabled ~= nil and type(entry.enabled) ~= "boolean" then return "enabled must be a boolean" end
    if entry.description ~= nil and type(entry.description) ~= "string" then return "description must be a string" end
    local _, err = scope_name(entry.submap); if err then return err end
    if entry.action ~= nil and entry.build_action ~= nil then return "use either action or build_action" end
    if entry.build_action ~= nil and type(entry.build_action) ~= "function" then return "build_action must be a function" end
    if entry.action ~= nil then
        local kind = type(entry.action)
        if kind ~= "function" and kind ~= "userdata" and kind ~= "table" then return "action must be a dispatcher or callback" end
    end
    if not partial and not entry.prefix and entry.action == nil and entry.build_action == nil then
        return "binding needs action or build_action"
    end
    return validate_options(entry.options)
end

local function merge(base, patch)
    local out = copy(base or {})
    if patch then
        if patch.action ~= nil then out.build_action = nil end
        if patch.build_action ~= nil then out.action = nil end
        for field, value in pairs(patch) do
            if field == "options" then
                out.options = copy(out.options or {})
                for flag, setting in pairs(value) do out.options[flag] = copy(setting) end
            else out[field] = copy(value) end
        end
        if patch.description == nil and patch.options and (patch.options.description ~= nil or patch.options.desc ~= nil) then
            out.description = nil
        end
    end
    return out
end

local function ordered(list, report, label)
    if type(list) ~= "table" then report(label .. " must return a table"); return {} end
    local indices, names, out = {}, {}, {}
    for key in pairs(list) do
        if type(key) == "number" and key >= 1 and key % 1 == 0 then indices[#indices + 1] = key
        elseif type(key) == "string" and key ~= "" then names[#names + 1] = key
        else report(label .. ": invalid list index") end
    end
    table.sort(indices); table.sort(names)
    for _, index in ipairs(indices) do out[#out + 1] = {value = list[index], label = label .. " #" .. index} end
    for _, name in ipairs(names) do out[#out + 1] = {value = list[name], name = name, label = label .. " '" .. name .. "'"} end
    return out
end

function M.register(definitions, custom_loader)
    local result = {registered = 0, problems = {}, handles = {}}
    local function report(message)
        result.problems[#result.problems + 1] = message
        print("[Hyprland config] keybinds: " .. message)
    end
    local defaults, order = {}, {}
    for _, item in ipairs(ordered(definitions, report, "core")) do
        local entry = item.value
        local id = type(entry) == "table" and (entry.id or item.name)
        if type(id) ~= "string" or id == "" then report(item.label .. ": core binding needs an id")
        elseif defaults[id] then report("duplicate core binding '" .. id .. "' ignored")
        else defaults[id] = copy(entry); defaults[id].id = id; order[#order + 1] = id end
    end
    local custom = {}
    if custom_loader then
        local ok, value = pcall(custom_loader)
        if not ok then
            if not tostring(value):match("^module 'custom%.keybinds' not found") then report("custom.keybinds failed to load: " .. tostring(value)) end
        elseif value ~= nil and value ~= true then custom = value end
    end
    local patches, legacy, patch_order = {}, {}, {}
    for _, item in ipairs(ordered(custom, report, "custom")) do
        local entry = item.value
        local id = item.name
        if id == nil and type(entry) == "table" then id = entry.id end
        if id ~= nil then
            if type(id) ~= "string" or id == "" then report(item.label .. ": id must be a nonempty string")
            elseif patches[id] ~= nil then report("duplicate custom binding '" .. id .. "' ignored")
            elseif type(entry) ~= "table" then patches[id] = false; report(item.label .. ": binding must be a table")
            elseif item.name and entry.id ~= nil and entry.id ~= id then report(item.label .. ": mismatched id field")
            else patches[id] = copy(entry); patches[id].id = id; patch_order[#patch_order + 1] = id end
        else legacy[#legacy + 1] = item end
    end
    for _, id in ipairs(patch_order) do if not defaults[id] then order[#order + 1] = id end end

    -- Prefix controls are metadata records; their effective keys feed generated children.
    local prefixes = {}
    for _, id in ipairs(order) do
        local base, patch = defaults[id], patches[id]
        if base and base.prefix then
            local err
            if type(patch) == "table" then
                for field in pairs(patch) do
                    if field ~= "id" and field ~= "key" and field ~= "enabled" then err = "workspace prefixes support only key and enabled" end
                end
                err = err or validate(patch, true, true)
            end
            if err then report("binding '" .. id .. "': " .. err .. "; using core prefix"); patch = nil end
            local effective = merge(base, type(patch) == "table" and patch or nil)
            err = validate(effective, false, false)
            if err then report("prefix '" .. id .. "': " .. err) else prefixes[id] = effective end
        end
    end
    local scope_order, scopes = {"default"}, {default = {}}
    local function add_plan(plan)
        local scope = scope_name(plan.preferred.submap)
        if not scopes[scope] then scopes[scope] = {}; scope_order[#scope_order + 1] = scope end
        scopes[scope][#scopes[scope] + 1] = plan
    end
    for _, id in ipairs(order) do
        local base, patch = defaults[id], patches[id]
        if not (base and base.prefix) then
            if base and base.internal and patch ~= nil then report("binding '" .. id .. "' is a protected cancellation binding"); patch = nil end
            local patch_err = type(patch) == "table" and validate(patch, true, true)
            if patch_err then report("binding '" .. id .. "': " .. patch_err .. "; using core binding"); patch = nil end
            local preferred = merge(base, type(patch) == "table" and patch or nil)
            preferred.id = id
            local parent = preferred.parent and prefixes[preferred.parent]
            if preferred.parent and not parent then report("binding '" .. id .. "': workspace prefix unavailable")
            elseif not (parent and parent.enabled == false) then
                if parent and not (type(patch) == "table" and patch.key ~= nil) then preferred.key = parent.key .. " + " .. preferred.suffix end
                local err = validate(preferred, false, false)
                if err then
                    report("binding '" .. id .. "': " .. err .. (base and "; using core binding" or ""))
                    preferred = base and copy(base) or nil
                    if preferred and validate(preferred, false, false) then preferred = nil end
                end
                if preferred and (preferred.internal or preferred.enabled ~= false) then
                    preferred.enabled = true
                    add_plan({id = id, preferred = preferred, base = base})
                end
            end
        end
    end
    local legacy_by_key, legacy_order = {}, {}
    local function identity(entry)
        local normalized = normalize(entry.key)
        local scope = scope_name(entry.submap)
        return scope .. ":" .. normalized
    end
    for _, item in ipairs(legacy) do
        local err = validate(item.value, false, true)
        if err then report(item.label .. ": " .. err)
        elseif item.value.enabled ~= false then
            local entry = copy(item.value); local key = identity(entry)
            if legacy_by_key[key] then report("duplicate custom shortcut '" .. entry.key .. "' ignored")
            else legacy_by_key[key] = entry; legacy_order[#legacy_order + 1] = entry end
        end
    end
    for _, entry in ipairs(legacy_order) do
        local scope = scope_name(entry.submap)
        if not scopes[scope] then scopes[scope] = {}; scope_order[#scope_order + 1] = scope end
    end
    local occupied, handled, cache = {}, {}, {}
    local function try_entry(entry, plan)
        local key = identity(entry)
        if occupied[key] then report("binding '" .. (plan.id or entry.key) .. "': shortcut already registered: " .. entry.key); return false, "collision" end
        local options = copy(entry.options or {})
        if entry.description ~= nil then options.description = entry.description end
        local action
        if entry.build_action then
            local built = cache[plan]
            if not built then built = {}; cache[plan] = built end
            local factory = entry.build_action
            if not built[factory] then
                local ok, value = pcall(factory)
                local kind = type(value)
                built[factory] = {ok = ok and (kind == "function" or kind == "userdata" or kind == "table"), value = value}
            end
            local constructed = built[factory]
            if not constructed.ok then
                report("binding '" .. (plan.id or entry.key) .. "': builder failed: " .. tostring(constructed.value)); return false, "failure"
            end
            action = constructed.value
        else action = entry.action end
        local ok, handle
        local function bind() ok, handle = pcall(hl.bind, entry.key, action, options) end
        local scope = scope_name(entry.submap)
        if scope == "default" then bind()
        else
            local scoped_ok, scoped_err = pcall(hl.define_submap, scope, bind)
            if not scoped_ok then ok, handle = false, scoped_err end
        end
        if not ok or handle == nil or handle == false then
            report("binding '" .. (plan.id or entry.key) .. "': registration failed: " .. tostring(handle)); return false, "failure"
        end
        occupied[key] = true; result.registered = result.registered + 1
        if plan.id then result.handles[plan.id] = handle end
        return true
    end
    for _, scope in ipairs(scope_order) do
        local pending = {}
        for _, plan in ipairs(scopes[scope]) do
            local entry, base = plan.preferred, plan.base
            local key = identity(entry)
            local replacement = legacy_by_key[key]
            if replacement then handled[key] = true end
            if replacement and entry.internal then report("binding '" .. plan.id .. "' is a protected cancellation binding"); replacement = nil end
            local candidates = {}
            if replacement then candidates[#candidates + 1] = replacement end
            candidates[#candidates + 1] = entry
            if base and not validate(base, false, false) then
                local fallback = copy(base)
                fallback.key, fallback.submap, fallback.enabled = entry.key, entry.submap, true
                if not same(fallback, entry) then candidates[#candidates + 1] = fallback end
            end
            local bound, reason
            for _, candidate in ipairs(candidates) do
                bound, reason = try_entry(candidate, plan)
                if bound or reason == "collision" then break end
            end
            if not bound and reason ~= "collision" and base and not validate(base, false, false) and identity(base) ~= key then
                pending[#pending + 1] = plan
            end
        end
        for _, entry in ipairs(legacy_order) do
            local key = identity(entry)
            if scope_name(entry.submap) == scope and not handled[key] then try_entry(entry, {}) end
        end
        -- Preserve valid configured keys before recovering failed remaps to core keys.
        for _, plan in ipairs(pending) do try_entry(plan.base, plan) end
    end
    if #result.problems > 0 then
        pcall(hl.notification.create, {text = ("Keybinds: %d problem(s). Run hyprctl rollinglog for details."):format(#result.problems),
            timeout = 8000, icon = "warning"})
    end
    return result
end

return M
