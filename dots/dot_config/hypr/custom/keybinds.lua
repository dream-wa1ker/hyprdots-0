-- ~/.config/hypr/custom/keybinds.lua
-- A custom entry replaces the default bound to the same key combination.

local vars = require("hyprland.variables")
local fn   = require("hyprland.functions")
local kb   = vars.keybinds

local cmd     = fn.editor_command()
local ruleKey = fn.editor_rule_key()

return {
    {
        key     = kb.editor,
        action  = hl.dsp.exec_cmd(cmd),
        options = { description = "Editor" },
    },
    {
        key     = kb.floatingEditor,
        action  = hl.dsp.exec_cmd(cmd, fn.floatSpawnRule(ruleKey, { float = true })),
        options = { description = "Floating editor" },
    },
}
