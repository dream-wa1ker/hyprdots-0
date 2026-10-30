-- YOUR ONLY KEYBINDING CONFIGURATION FILE. Add records inside the return table below.
-- ADD NEW: give a unique id, key, description, and build_action (or action):
-- {
--     id = "myShortcut",
--     key = "SUPER + ALT + Y",
--     description = "Open system monitor",
--     build_action = function() return hl.dsp.exec_cmd("kitty -e btop") end,
-- },
-- EDIT CORE: { id = "terminal", key = "SUPER + ALT + Return" },
-- DISABLE CORE: { id = "mediaStop", enabled = false },
-- Omitted fields inherit the core record. Edit existing custom records in place;
-- do not add a second record with the same id. First duplicate wins, with a warning.
--
-- key: XKB shortcut string. enabled: false skips registration and builder construction.
-- description: cheatsheet label. options: key-press flags, merged individually:
--   repeating, locked, release, mouse, etc. Explicit false clears an inherited flag.
-- Floating is WINDOW behavior: use apps.launch("terminal", { floating = true })
-- inside build_action. Geometry/app commands remain in custom/variables.lua's apps table.
-- build_action runs on LOAD and RETURNS a dispatcher/callback; do not execute commands then.
-- action = function() ... end runs WHEN PRESSED. Use hl.dispatch(...) for multiple actions.
-- Defining one clears an inherited counterpart; never supply both.
-- New bindings may set submap = "geometry" (or a named submap) to limit their scope.
-- Workspace prefix IDs affect all ten generated children; a disabled family stays disabled.
-- Placement Escape/catchall exits are protected against custom overrides.
-- Invalid overrides fall back to their core binding; one bad entry does not stop others.
-- Save this file to reload. Inspect errors with hyprctl configerrors / hyprctl rollinglog.
-- Core defaults: hyprland/keybinds.lua. Do not call hl.bind directly here.

local fn   = require("hyprland.functions")
local apps = require("hyprland.lib.apps")

return {
    -- Active ---------------------------------------------------------------------
    {
        id = "powerSaver",
        key = "SUPER + ALT + B",
        build_action = function()
            return fn.power_saver_toggle
        end,
        description = "Power saver: blur, rounding, shadows, animations off; shell stopped",
    },

    {
        id = "customEditKeybinds",
        key = "CTRL + SUPER + ALT + Slash",
        build_action = function()
            local home = assert(os.getenv("HOME"), "HOME is not set")
            local path = home .. "/.config/hypr/custom/keybinds.lua"
            return apps.launch("editor", { args = { path } })
        end,
        description = "Edit Custom Keybindings",
    },
    {
        id = "customCloseWindow",
        key = "SUPER + Q",
        build_action = function()
            return hl.dsp.window.close()
        end,
        description = "Close Active Window",
    },

    -- Change only a core shortcut (inherits its behavior):
    -- { id = "terminal", key = "SUPER + ALT + Return" },
    -- Disable a core binding:
    -- { id = "mediaStop", enabled = false },
    -- Change behavior and flags, keeping the core shortcut:
    -- {
    --     id = "browser",
    --     build_action = function() return apps.launch("browser", { floating = true }) end,
    --     options = { release = true },
    -- },
    -- Change a numbered-workspace family or just one generated binding:
    -- { id = "goToWorkspacePrefix", key = "SUPER + ALT" },
    -- { id = "workspace.focus.3", key = "SUPER + F3" },
    -- Remap a placement preset (still scoped to placement mode):
    -- { id = "geometryLeft", key = "Left" },
}
