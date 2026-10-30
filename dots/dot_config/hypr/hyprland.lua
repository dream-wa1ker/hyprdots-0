-- ~/.config/hypr/hyprland.lua
-- dream-wa1ker
-- Core defaults load first. Custom modules return declarative Lua tables;
-- this loader applies those tables using the matching Hyprland API.

local home = assert(os.getenv("HOME"), "HOME is not set")
local hypr = home .. "/.config/hypr"
local customDir = hypr .. "/custom"

local boot = require("core.bootstrap")

-- Internal libraries
local lib = boot.safe_require("hyprland.lib")
local customConfig = boot.safe_require("hyprland.lib.create_custom_config")

local function is_file_exists(path)
    if type(lib) == "table" and type(lib.is_file_exists) == "function" then
        return lib.is_file_exists(path)
    end

    local file = io.open(path, "r")
    if file then
        file:close()
        return true
    end
    return false
end

local function custom_file_exists(name)
    return is_file_exists(customDir .. "/" .. name .. ".lua")
end

-- Load declarative custom modules only when their files exist. A custom
-- module should return a table; it should not call hl.* while being required.
local function load_custom_spec(name)
    if not custom_file_exists(name) then
        return nil
    end

    local spec = boot.safe_require("custom." .. name)
    if spec == nil or spec == true then
        -- An empty Lua module commonly returns `true` from require(); treat
        -- empty custom template files as no overrides.
        return nil
    end
    if type(spec) ~= "table" then
        hl.notification.create({
            text = "Custom config '" .. name .. "' must return a Lua table",
            duration = 6000,
            icon = "warning",
        })
        return nil
    end
    return spec
end

local function as_array(value)
    if type(value) ~= "table" then
        return {}
    end
    return value
end

local function apply_config(spec, label)
    local config = spec.config or spec
    if type(config) == "table" and next(config) ~= nil then
        boot.safe_call(hl.config, label)(config)
    end
end

local function apply_rule_list(fn, rules, label)
    if type(rules) == "table" then
        boot.apply_all(fn, rules, label)
    end
end

-- Apply declarative custom specs for ordinary Hyprland modules. Supported
-- contracts are documented below the loader code and in custom/*.lua.
local function apply_custom_spec(name, spec)
    if name == "env" then
        local entries = spec.env or spec
        for key, value in pairs(entries) do
            if type(key) == "string" and value ~= nil then
                boot.safe_call(hl.env, "custom.env")(key, value)
            end
        end

    elseif name == "general" or name == "input" or name == "misc"
        or name == "decoration" or name == "group" then
        apply_config(spec, "custom." .. name)

    elseif name == "animations" then
        if spec.config then
            apply_config(spec, "custom.animations")
        end

        -- Curves may be written as a name -> definition map, or as an array
        -- of { name = "curveName", config = { ... } } entries.
        for key, curve in pairs(as_array(spec.curves)) do
            if type(curve) == "table" then
                local curveName = curve.name or (type(key) == "string" and key or nil)
                local curveConfig = curve.config or curve.value or curve
                if curveName then
                    boot.safe_call(hl.curve, "custom.animations.curve")(curveName, curveConfig)
                end
            end
        end
        apply_rule_list(hl.animation, spec.animations, "custom.animations.animation")

    elseif name == "rules" then
        apply_rule_list(hl.window_rule, spec.window or spec.window_rules, "custom.rules.window")
        apply_rule_list(hl.workspace_rule, spec.workspace or spec.workspace_rules, "custom.rules.workspace")
        apply_rule_list(hl.layer_rule, spec.layer or spec.layer_rules, "custom.rules.layer")

    elseif name == "gestures" then
        if spec.config then
            apply_config(spec, "custom.gestures")
        end
        apply_rule_list(hl.gesture, spec.gestures, "custom.gestures.gesture")

    elseif name == "execs" then
        -- Startup commands are declarative strings, run when Hyprland starts.
        local startup = as_array(spec.startup)
        if #startup > 0 then
            hl.on("hyprland.start", function()
                for _, command in ipairs(startup) do
                    if type(command) == "string" and command ~= "" then
                        hl.exec_cmd(command)
                    end
                end
            end)
        end

        -- Optional event handlers for cases that need an actual Lua callback:
        -- { event = "hyprland.start", callback = function() ... end }
        for _, eventSpec in ipairs(as_array(spec.events)) do
            if type(eventSpec) == "table"
                and type(eventSpec.event) == "string"
                and type(eventSpec.callback) == "function" then
                hl.on(eventSpec.event, eventSpec.callback)
            end
        end

    elseif name == "colors" then
        -- Applied after Noctalia's generated theme, so explicit custom color
        -- overrides win rather than being overwritten by apply_theme().
        apply_config(spec, "custom.colors")
    end
end

-- Variable overrides are the one custom table that must be merged BEFORE
-- core modules read variables.lua. It should return either a raw variable
-- table or { variables = { ... } }.
local vars = boot.safe_require("hyprland.variables")
-- Keep pristine shortcut strings available if a custom variable is invalid.
local keybindRegistry = boot.safe_require("hyprland.lib.keybinds")
if type(vars) == "table" and type(keybindRegistry) == "table" then
    keybindRegistry.capture_defaults(vars.keybinds)
end
local customVars = load_custom_spec("variables")
if type(vars) == "table" and type(customVars) == "table" then
    local apps = boot.safe_require("hyprland.lib.apps")
    if type(apps) == "table" then
        apps.merge_overrides(vars, customVars.variables or customVars, boot.deep_merge)
    else
        boot.deep_merge(vars, customVars.variables or customVars)
    end
end

-- Keep kb.<id> strings available to custom files; richer policies stay in the registry.
if type(vars) == "table" and type(keybindRegistry) == "table" then
    keybindRegistry.resolve_settings(vars)
end

-- Default monitor configuration
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1,
})

-- Core modules load in dependency order. custom.functions is merged into the
-- already-loaded functions table immediately before keybinds are constructed,
-- so keybindings can reference custom functions through `fn`.
local modules = {
    "env",
    "general",
    "input",
    "misc",
    "animations",
    "decoration",
    "group",
    "functions",
    "execs",
    "rules",
    "gestures",
    "keybinds",
}

-- Make sure every override file exists (never overwrites).
if type(customConfig) == "table" then
    local unpack = table.unpack or unpack
    boot.safe_call(customConfig.ensure, "lib.create_custom_config")(
        customDir,
        { "variables", "colors", unpack(modules) }
    )
end

local customSpecs = {}
for _, name in ipairs(modules) do
    if name == "keybinds" then
        local customFunctions = load_custom_spec("functions")
        if type(customFunctions) == "table" then
            local baseFunctions = boot.safe_require("hyprland.functions")
            if type(baseFunctions) == "table" then
                boot.deep_merge(baseFunctions, customFunctions.functions or customFunctions)
            end
        end
    end

    boot.safe_require("hyprland." .. name)

    -- custom.keybinds is deliberately NOT loaded here: hyprland.keybinds
    -- imports it as data, resolves custom precedence, then registers bindings
    -- once. Loading it as a post-default override would be redundant/wrong.
    if name ~= "keybinds" and name ~= "variables" and name ~= "functions" then
        local spec = load_custom_spec(name)
        if spec then
            customSpecs[name] = spec
            apply_custom_spec(name, spec)
        end
    end
end

-- Dynamic display and workspace configurations (e.g. nwg-displays)
if is_file_exists(hypr .. "/workspaces.lua") then
    boot.safe_require("workspaces")
end

if is_file_exists(hypr .. "/monitors.lua") then
    boot.safe_require("monitors")
end

-- Shell overrides
boot.safe_require("hyprland.shellOverrides.main")

-- Apply Noctalia's generated theme first, then user color overrides.
local noctalia = boot.safe_require("noctalia")
if type(noctalia) == "table" and type(noctalia.apply_theme) == "function" then
    noctalia.apply_theme()
end

local customColors = customSpecs.colors or load_custom_spec("colors")
if type(customColors) == "table" then
    apply_custom_spec("colors", customColors)
end

-- Declarative custom module contracts:
--
-- custom/variables.lua:
--   return { variables = { windowOpacity = 0.95,
--       apps = { editor = { command = "kate", terminal = false } } } }
--
-- custom/env.lua:
--   return { env = { MY_ENV_VAR = "value" } }
--
-- custom/general.lua, input.lua, misc.lua, decoration.lua, group.lua:
--   return { config = { general = { ... } } } -- pass any hl.config-compatible table
--
-- custom/animations.lua:
--   return { config = { animations = { enabled = true } },
--            curves = { example = { type = "bezier", points = {{0.1, 0.2}, {0.3, 1}} } },
--            animations = { { leaf = "windowsIn", enabled = true, speed = 4, bezier = "example" } } }
--
-- custom/rules.lua:
--   return { window = { { match = { class = "example" }, float = true } },
--            workspace = { ... }, layer = { ... } }
--
-- custom/gestures.lua:
--   return { config = { gestures = { workspace_swipe_distance = 600 } },
--            gestures = { { fingers = 3, direction = "horizontal", action = "workspace" } } }
--
-- custom/execs.lua:
--   return { startup = { "command-one", "command-two" } }
--
-- custom/functions.lua:
--   return { functions = { my_action = function() ... end } }
--   Reference as `fn.my_action` from custom/keybinds.lua.
--
-- custom/keybinds.lua:
--   Return an array of { key = ..., action = ..., options = {...} } records.
--   hyprland.keybinds.lua loads this module and gives custom records precedence.
--
-- custom/colors.lua:
--   return { config = { general = { col = { active_border = "rgb(...)" } } } }

