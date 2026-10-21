-- ~/.config/hypr/custom/functions.lua
-- dream-wa1ker
--
-- PURPOSE   Your own helper functions, available as `fn.<name>` inside custom/keybinds.lua.
-- RETURNS   { functions = { name = function, ... } }
-- LOADED    After hyprland/functions.lua, right before keybinds are built. A name defined
--           here REPLACES a built-in of the same name, so choose unique names.
-- RULES     1. No side effects: no hl.* calls at load time, only definitions.
--           2. Declare everything `local`; accidental globals leak into every other file.

local vars = require("hyprland.variables")

-- bind(key, action [, description [, flags]]) -> one entry for custom/keybinds.lua
--   key          "SUPER + SHIFT + B" (see custom/keybinds.lua for the syntax)
--   action       a dispatcher, e.g. hl.dsp.exec_cmd("kitty")
--   description  shown by the keybind cheatsheet; always worth setting
--   flags        optional table: { repeating = true, locked = true, release = true, mouse = true }
local function bind(key, action, description, flags)
    local options = { description = description }
    for name, value in pairs(flags or {}) do
        options[name] = value
    end
    return { key = key, action = action, options = options }
end

-- Editors that draw inside a terminal and therefore need one to run.
local TERMINAL_EDITORS = {
    nvim = true, vim = true, vi = true, nano = true,
    hx = true, helix = true, micro = true,
}

local function needs_terminal(cmd)
    -- An explicit `editorInTerminal` in custom/variables.lua wins over detection.
    if vars.editorInTerminal ~= nil then
        return vars.editorInTerminal
    end
    local first = cmd:match("^%S+") or ""          -- first word of the command
    local bin   = first:match("([^/]+)$") or first -- strip any leading path
    return TERMINAL_EDITORS[bin] == true
end

local function editor_command()
    if needs_terminal(vars.editor) then
        return vars.terminal .. " -e " .. vars.editor
    end
    return vars.editor
end

-- Key for the floating-size lookup: the terminal if we wrap the editor in one,
-- otherwise the editor itself.
local function editor_rule_key()
    return needs_terminal(vars.editor) and vars.terminal or vars.editor
end

return {
    functions = {
        bind            = bind,
        editor_command  = editor_command,
        editor_rule_key = editor_rule_key,
    },
}
