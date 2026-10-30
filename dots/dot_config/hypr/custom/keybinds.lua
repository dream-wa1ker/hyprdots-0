-- HOW TO ADD A SHORTCUT (edit the existing tables; do not replace either file):
-- 1. In custom/variables.lua, inside keybinds = { ... }, add:
--      myShortcut = { key = "SUPER + ALT + Y" },
-- 2. In THIS file, inside return { ... }, add:
--      {
--          id = "myShortcut",
--          description = "Open system monitor",
--          build_action = function() return hl.dsp.exec_cmd("kitty -e btop") end,
--      },
-- The setting name and id must match. End each entry with a comma, then save both files.
--
-- CHANGE KEYS: change only the matching entry in custom/variables.lua.
-- CHANGE BEHAVIOR: add an entry here using an existing core id (e.g. "terminal").
-- DISABLE: put mediaStop = { enabled = false } in custom/variables.lua's keybinds table.
-- Core IDs/behavior: hyprland/keybinds.lua. Core shortcut defaults: hyprland/variables.lua.
--
-- build_action runs during loading and RETURNS a dispatcher/callback; do not launch then.
-- action = function() ... end runs WHEN PRESSED; use it for multiple operations.
-- apps.launch("browser") builds a launch dispatcher using the configured application.
-- Reusable callbacks from custom/functions.lua are available through fn.
-- Failed replacements fall back to their built-in definition. Do not call hl.bind here.

local fn   = require("hyprland.functions")
local apps = require("hyprland.lib.apps")

return {
    -- Active ---------------------------------------------------------------------
    {
        id = "powerSaver",
        build_action = function()
            return fn.power_saver_toggle
        end,
        options = {
            description = "Power saver: blur, rounding, shadows, animations off; shell stopped",
        },
    },

    {
        id = "customEditKeybinds",
        build_action = function()
            local home = assert(os.getenv("HOME"), "HOME is not set")
            local path = home .. "/.config/hypr/custom/keybinds.lua"
            return apps.launch("editor", { args = { path } })
        end,
        options = { description = "Edit Custom Keybindings" },
    },
    {
        id = "customCloseWindow",
        build_action = function()
            return hl.dsp.window.close()
        end,
        options = { description = "Close Active Window" },
    },

    -- Named override example: keeps the browser shortcut configured in variables.lua.
    -- browser = {
    --     build_action = function() return apps.launch("browser", { floating = true }) end,
    -- },
}
