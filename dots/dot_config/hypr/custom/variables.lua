-- ~/.config/hypr/custom/variables.lua
-- Override defaults before modules load. Raw tables and { variables = { ... } } work.
-- Application defaults live in hyprland/variables.lua; helpers live in lib/apps.lua.
-- apps.<id> fields merge individually; classes and exec_args replace entire lists.
-- Geometry merges w/h (logical pixels) or wp/hp (full-monitor fractions), never both.
-- center = true clears saved offsets; x/y are monitor-local and supplied together.
-- Invalid application/geometry patches are logged and retain the previous valid record.
-- auto_float = false disables a generated rule, not floating launch shortcuts.
-- terminal = true wraps an app in apps.terminal; set false when switching to a GUI editor.
-- Terminal-wrapped apps share the actual terminal's window classes for runtime matching.

return {
    windowOpacity = 0.85,
    blurSize = 6,

    -- Application examples: uncomment only what you want to change.
    -- apps = {
    --     terminal = { command = "foot", classes = { "foot" }, exec_args = { "-e" } },
    --     browser = { command = "firefox", classes = { "firefox" } },
    --     editor = { command = "kate", terminal = false },
    --     fileManager = { geometry = { w = 1100, h = 700, center = true } },
    --     appearance = { geometry = { wp = 0.55, hp = 0.65 }, auto_float = false },
    --     myTool = { command = "my-tool", classes = { "my-tool" },
    --         geometry = { wp = 0.5, hp = 0.6 }, auto_float = true },
    -- },

    -- blurPasses = 2,
    -- windowGapsIn = 3,
    -- cursorSize = 24,
    -- autostartKdeConnect = false, -- next login; does not stop a running process

    -- Shortcut names stay unchanged. Move other actions if a new key is occupied.
    keybinds = {
        powerSaver = "SUPER + ALT + B",
        -- geometryMode = "SUPER + ALT + Z",
        -- geometryLeft = "Left",
        -- browser = "SUPER + SHIFT + B",
        -- floatingBrowser = "SUPER + B",
    },
}
