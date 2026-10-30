-- ~/.config/hypr/custom/keybinds.lua
-- dream-wa1ker
--
-- PURPOSE   Add keybindings, or replace a default one.
-- RETURNS   A list of entries: { key = ..., action = ..., options = { ... } }
--           Or use build_action = function() return dispatcher_or_callback end.
--           Builders run once at load time, protected separately for each entry.
--           Build them with fn.bind(key, action, description [, flags]) (defined in
--           custom/functions.lua); it fills in the table for you.
-- LOADED    Evaluated by hyprland/keybinds.lua, which resolves precedence and then
--           registers every binding once. Do not call hl.bind yourself here.
--
-- KEY SYNTAX   Modifiers and key joined with " + ":
--                "SUPER + SHIFT + B"   "ALT + Tab"   "XF86AudioMute"   "SUPER + mouse:272"
--              Modifiers: SUPER, SHIFT, CTRL, ALT. Key names are xkb names
--              (Return, Space, Page_Up, F11, Print ...). Run `wev` and press a key to see its name.
--
-- PRECEDENCE   A custom entry replaces its default only after successful registration.
--              Failed construction/registration falls back to the default.
--              Two custom entries on one combination: the first is kept, the second is
--              reported and ignored. A bad entry never stops the others (see hyprctl rollinglog).
--
-- OPTIONS      All optional. `description` feeds the keybind cheatsheet, so always set it.
--                description = "text"
--                repeating   = true   -- keep firing while the key is held (volume, resize)
--                locked      = true   -- also works while the screen is locked (media keys)
--                release     = true   -- fire when the key is released
--                mouse       = true   -- a mouse binding (drag / resize)
--
-- DEFAULT NAMES  `kb.<name>` is the default shortcut of an action, e.g. kb.editor.
--              The full list is the `keybinds` table in hyprland/variables.lua.
--              Using kb.<name> as the key replaces that default; a literal string adds a new one.
--
-- CAUTION      exec_cmd runs a shell command with your full privileges. Never build the
--              command from untrusted text (a window title, a filename): shell characters
--              in it would execute.

local vars = require("hyprland.variables")
local fn   = require("hyprland.functions")
local lib  = require("hyprland.lib")
local kb   = type(vars.keybinds) == "table" and vars.keybinds or {}

return {
    -- Active ---------------------------------------------------------------------
    {
        key = kb.editor,
        build_action = function()
            return hl.dsp.exec_cmd(fn.editor_command())
        end,
        options = { description = "Editor" },
    },
    {
        key = kb.floatingEditor,
        build_action = function()
            return hl.dsp.exec_cmd(
                fn.editor_command(),
                fn.floatSpawnRule(fn.editor_rule_key(), { float = true })
            )
        end,
        options = { description = "Floating editor" },
    },
    {
        key = kb.powerSaver,
        build_action = function()
            return fn.power_saver_toggle
        end,
        options = {
            description = "Power saver: blur, rounding, shadows, animations off; shell stopped",
        },
    },

    {
        key = kb.customEditKeybinds,
        build_action = function()
            local home = assert(os.getenv("HOME"), "HOME is not set")
            local path = home .. "/.config/hypr/custom/keybinds.lua"
            return hl.dsp.exec_cmd(fn.editor_command() .. " " .. lib.shell_quote(path))
        end,
        options = { description = "Edit Custom Keybindings" },
    },
    {
        key = kb.customCloseWindow,
        build_action = function()
            return hl.dsp.window.close()
        end,
        options = { description = "Close Active Window" },
    },

    -- Examples: remove the leading `--` to enable --------------------------------
    -- fn.bind("SUPER + ALT + T", hl.dsp.exec_cmd(vars.terminal .. " -e btop"), "System monitor"),
    -- fn.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
    --         "Mute", { locked = true }),
}
