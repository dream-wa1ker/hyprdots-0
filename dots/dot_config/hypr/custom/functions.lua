-- ~/.config/hypr/custom/functions.lua
-- Helpers merged into `fn` before keybinds are built.

local vars = require("hyprland.variables")

-- Editors that draw inside a terminal and need one to run.
local TERMINAL_EDITORS = {
    nvim = true, vim = true, vi = true, nano = true,
    hx = true, helix = true, micro = true,
}

local function needs_terminal(cmd)
    -- Explicit override in custom/variables.lua wins over detection.
    if vars.editorInTerminal ~= nil then
        return vars.editorInTerminal
    end
    local first = cmd:match("^%S+") or ""      -- first word of the command
    local bin   = first:match("([^/]+)$") or first -- strip any leading path
    return TERMINAL_EDITORS[bin] == true
end

local function editor_command()
    if needs_terminal(vars.editor) then
        return vars.terminal .. " -e " .. vars.editor
    end
    return vars.editor
end

-- Key used to look up the floating size rule: the terminal if we
-- wrap the editor in one, otherwise the editor itself.
local function editor_rule_key()
    return needs_terminal(vars.editor) and vars.terminal or vars.editor
end

return {
    functions = {
        editor_command  = editor_command,
        editor_rule_key = editor_rule_key,
    },
}
