-- ~/.config/hypr/custom/variables.lua
-- dream-wa1ker
--
-- PURPOSE     Override values from hyprland/variables.lua (apps, gaps, blur, sizes,
--             shortcut strings). Every other file reads these values.
-- RETURNS     A table. List ONLY what differs from the default; a value equal to
--             the default is noise. ({ variables = { ... } } is also accepted.)
-- LOADED      First: merged into the defaults before any other module reads them,
--             so one line here changes every file that uses that variable.
-- FIND NAMES  Every overridable name lives in hyprland/variables.lua:
--                 grep -n "=" ~/.config/hypr/hyprland/variables.lua | less
--             Nested tables (keybinds, floatRules) merge key by key, so you can
--             change one shortcut without repeating the others.
--             Float geometry switches cleanly between w/h and wp/hp; invalid overrides
--             are logged and retain the previous valid specification.
--             x/y are logical monitor-local offsets; center = true removes saved offsets.
--             auto_float = false disables an application's generated floating rule.
-- RULE OF THUMB  If a variable exists (windowOpacity, blurPasses, terminal ...) set
--             it here. Options with no variable go in the matching custom file
--             (decoration.lua, input.lua, misc.lua ...).

return {
    -- Active overrides ---------------------------------------------------------
    windowOpacity = 0.85, -- default 0.85
    blurSize      = 6,    -- default 8

    -- Examples: remove the leading `--` to enable --------------------------------
    -- terminal  = "foot",
    -- browser   = "firefox",
    -- editor    = "nvim",       -- terminal editors are wrapped in a terminal by custom/functions.lua
    -- editorInTerminal = true,  -- force that wrapping for an editor custom/functions.lua does not know
    -- blurPasses   = 2,         -- cheaper on integrated graphics
    -- windowGapsIn = 3,
    -- cursorSize   = 24,
    -- autostartKdeConnect = false, -- disable the indicator at the next login; does not stop a running process

    -- Geometry examples (the default values live in hyprland/variables.lua):
    -- floatRules = {
    --     ["org.kde.dolphin"] = { w = 1100, h = 700, center = true },
    --     ["nwg-look"] = { wp = 0.55, hp = 0.65 },
    -- },

    -- Shortcuts: the VALUE is the key combination, the NAME is the action. Names are
    -- listed in the `keybinds` table of hyprland/variables.lua. The loader reports
    -- duplicates, so if the new combination is taken, move the other action too.
    keybinds = {
        powerSaver = "SUPER + ALT + B", -- power saver on/off, see custom/functions.lua
        -- geometryMode = "SUPER + ALT + Z", -- enter placement mode
        -- geometryLeft = "Left", -- only inside placement mode
        -- browser         = "SUPER + SHIFT + B",
        -- floatingBrowser = "SUPER + B",
    },
}
