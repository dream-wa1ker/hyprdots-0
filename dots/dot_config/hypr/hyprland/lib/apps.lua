-- Application records, validated overrides, launch commands, and floating rules.
-- Requiring this library has no compositor or filesystem side effects.
local vars = require("hyprland.variables")
local geometry = require("hyprland.lib.geometry")
local lib = require("hyprland.lib")
local M = {}
local fields = {command = true, terminal = true, classes = true,
    geometry = true, auto_float = true, exec_args = true}

local function copy(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for key, item in pairs(value) do result[key] = copy(item) end
    return result
end

local function string_list(value, label)
    if type(value) ~= "table" then return nil, label .. " must be a list" end
    local count = 0
    for key, item in pairs(value) do
        if type(key) ~= "number" or key % 1 ~= 0 or key < 1
            or type(item) ~= "string" or item == "" then
            return nil, label .. " must be a dense list of nonempty strings"
        end
        count = count + 1
    end
    for index = 1, count do
        if value[index] == nil then return nil, label .. " cannot contain holes" end
    end
    return true
end

local function validate(app)
    for key in pairs(app) do
        if not fields[key] then return nil, "unknown application field: " .. tostring(key) end
    end
    if app.command ~= nil and (type(app.command) ~= "string" or not app.command:match("%S")) then
        return nil, "command must be a nonempty string"
    end
    for _, key in ipairs({"terminal", "auto_float"}) do
        if app[key] ~= nil and type(app[key]) ~= "boolean" then return nil, key .. " must be a boolean" end
    end
    for _, key in ipairs({"classes", "exec_args"}) do
        if app[key] ~= nil then
            local ok, err = string_list(app[key], key)
            if not ok then return nil, err end
        end
    end
    if app.geometry ~= nil then
        local ok, err = geometry.validate_spec(app.geometry)
        if not ok then return nil, err end
    end
    if not app.command and not (app.classes and #app.classes > 0) then
        return nil, "application needs a command or window classes"
    end
    if app.auto_float and not (app.classes and #app.classes > 0) then
        return nil, "auto_float requires explicit window classes"
    end
    return true
end

-- Geometry merges by dimension mode; classes and exec_args replace whole lists.
function M.merge_app(base, patch)
    if type(patch) ~= "table" then return nil, "application override must be a table" end
    local candidate = copy(base or {})
    for key, value in pairs(patch) do
        if key ~= "geometry" then candidate[key] = copy(value) end
    end
    if patch.geometry ~= nil then
        local spec, err = geometry.merge_spec(candidate.geometry, patch.geometry)
        if not spec then return nil, err end
        candidate.geometry = spec
    end
    local ok, err = validate(candidate)
    if not ok then return nil, err end
    return candidate
end

function M.merge_overrides(target, overrides, deep_merge)
    local function warn(label, err)
        print("[Hyprland config] apps: " .. label .. ": " .. err)
    end
    if type(overrides) ~= "table" then
        warn("variables", "override must be a table")
        return target
    end
    local ordinary = {}
    for key, value in pairs(overrides) do
        if key == "keybinds" then
            warn("keybinds", "move shortcut overrides to custom/keybinds.lua; this obsolete setting is ignored")
        elseif key ~= "apps" and key ~= "defaultRule" then ordinary[key] = value end
    end
    deep_merge(target, ordinary)
    if overrides.defaultRule ~= nil then
        local spec, err = geometry.merge_spec(target.defaultRule, overrides.defaultRule)
        if spec then target.defaultRule = spec else warn("defaultRule", err) end
    end
    if overrides.apps ~= nil then
        if type(overrides.apps) ~= "table" then warn("apps", "must be a table")
        else
            for id, patch in pairs(overrides.apps) do
                if type(id) ~= "string" or id == "" then warn("apps", "IDs must be nonempty strings")
                else
                    local app, err = M.merge_app(target.apps[id], patch)
                    if app then target.apps[id] = app else warn(id, err) end
                end
            end
        end
    end
    return target
end

function M.ids()
    local ids = {}
    for id in pairs(vars.apps) do ids[#ids + 1] = id end
    table.sort(ids)
    return ids
end

function M.get(id)
    return assert(vars.apps[id], "Unknown application: " .. tostring(id))
end

-- IDs and commands are exact; window class aliases match case-insensitively.
function M.find(key)
    if type(key) ~= "string" then return nil end
    if vars.apps[key] then return vars.apps[key] end
    local ids = M.ids()
    for _, id in ipairs(ids) do
        if vars.apps[id].command == key then return vars.apps[id] end
    end
    for _, id in ipairs(ids) do
        local app = vars.apps[id]
        for _, class in ipairs(app.classes or {}) do
            if class:lower() == key:lower() then return app end
        end
    end
end

function M.geometry_for(key)
    local app = M.find(key)
    return app and app.geometry or vars.defaultRule
end

local function append_args(command, args)
    local ok, err = string_list(args, "args")
    assert(ok, err)
    for _, arg in ipairs(args) do command = command .. " " .. lib.shell_quote(arg) end
    return command
end

-- Commands are trusted shell fragments; appended positional arguments are quoted.
function M.command(id, args)
    local app = M.get(id)
    local command = assert(app.command, "Application has no launch command: " .. id)
    command = append_args(command, args or {})
    if app.terminal then
        assert(id ~= "terminal", "The terminal application cannot wrap itself")
        local terminal = M.get("terminal")
        local prefix = append_args(assert(terminal.command, "Terminal has no command"), terminal.exec_args or {"-e"})
        command = prefix .. " " .. command
    end
    return command
end

function M.float_rule(key, extra)
    local effects, err = geometry.rule_effects(M.geometry_for(key))
    assert(effects, err)
    for name, value in pairs(extra or {}) do effects[name] = value end
    return effects
end

-- Return a dispatcher: constructing a binding never launches an application.
function M.launch(id, options)
    options = options or {}
    local effects
    if options.floating or options.pseudo then
        effects = M.float_rule(id, {float = options.floating, pseudo = options.pseudo})
    end
    return hl.dsp.exec_cmd(M.command(id, options.args), effects)
end

function M.floating_rule(id)
    local app = M.get(id)
    if not app.auto_float then return nil end
    local ok, err = validate(app)
    assert(ok, id .. ": " .. tostring(err))
    local effects = M.float_rule(id, {float = true})
    effects.name = "float." .. id
    effects.match = {class = geometry.class_pattern(id, {classes = app.classes})}
    return effects
end

return M
