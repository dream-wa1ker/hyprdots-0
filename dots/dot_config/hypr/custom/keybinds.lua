-- ~/.config/hypr/custom/keybinds.lua
-- dream-wa1ker
--
-- PURPOSE   Add keybindings, or replace a default one.
-- RETURNS   A list of entries: { key = ..., action = ..., options = { ... } }
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
-- PRECEDENCE   A custom entry REPLACES the default bound to the same combination.
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
local kb   = vars.keybinds

local cmd     = fn.editor_command()
local ruleKey = fn.editor_rule_key()

return {
    -- Active ---------------------------------------------------------------------
    fn.bind(kb.editor,
        hl.dsp.exec_cmd(cmd),
        "Editor"),

    fn.bind(kb.floatingEditor,
        hl.dsp.exec_cmd(cmd, fn.floatSpawnRule(ruleKey, { float = true })),
        "Floating editor"),

    fn.bind(kb.powerSaver,
        fn.power_saver_toggle,
        "Power saver: blur, rounding, shadows, animations off; shell stopped"),

    -- Examples: remove the leading `--` to enable --------------------------------
    -- fn.bind("SUPER + Q", hl.dsp.window.close(), "Close window"),
    -- fn.bind("SUPER + ALT + T", hl.dsp.exec_cmd(vars.terminal .. " -e btop"), "System monitor"),
    -- fn.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
    --         "Mute", { locked = true }),
}
