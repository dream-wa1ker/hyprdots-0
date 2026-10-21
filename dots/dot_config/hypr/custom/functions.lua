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
local lib  = require("hyprland.lib")
local boot = require("core.bootstrap")

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

-- Power saver ------------------------------------------------------------------
-- One key toggles: blur, shadows, rounding and animations off, and the shell
-- (vars.shell, Noctalia) stopped. Pressing it again restores everything from the
-- values in vars, so overrides in custom/variables.lua are respected.
--
-- State is a marker file in $XDG_RUNTIME_DIR: a per-user directory (mode 0700) that is
-- emptied at logout. A predictable path in /tmp would let another local user pre-create
-- or symlink it.
-- After `hyprctl reload` the visuals reset but the marker stays; one key press then
-- restores (and restarts the shell), a second press turns the saver on again.
local runtime    = os.getenv("XDG_RUNTIME_DIR")
local STATE_FILE = runtime and (runtime .. "/hypr-power-saver") or nil

local function saver_active()
    return STATE_FILE ~= nil and lib.is_file_exists(STATE_FILE)
end

local function set_saver_state(on)
    if on then
        local f = io.open(STATE_FILE, "w")
        if f then
            f:write("1")
            f:close()
        end
    else
        os.remove(STATE_FILE)
    end
end

local function apply_saver(on)
    hl.config({
        animations = { enabled = not on },
        decoration = {
            rounding = on and 0 or vars.windowRounding,
            blur     = { enabled = (not on) and vars.blurEnabled },
            shadow   = { enabled = (not on) and vars.shadowEnabled },
        },
    })

    local shell = lib.shell_quote(vars.shell)
    if on then
        hl.exec_cmd("pkill -x -- " .. shell)
    else
        -- start the shell only if it is not already running
        hl.exec_cmd("pgrep -x -- " .. shell .. " >/dev/null || " .. shell)
    end
end

local power_saver_toggle = boot.safe_call(function()
    if not STATE_FILE then
        pcall(hl.notification.create, {
            text = "Power saver unavailable: XDG_RUNTIME_DIR is not set",
            duration = 4000, icon = "warning",
        })
        return
    end

    local turn_on = not saver_active()
    apply_saver(turn_on)
    set_saver_state(turn_on)

    -- Hyprland's own notification: the shell's daemon may be stopped.
    pcall(hl.notification.create, {
        text = turn_on and "Power saver ON (shell stopped)" or "Power saver OFF",
        duration = 2500, icon = "info",
    })
end, "powerSaverToggle")

return {
    functions = {
        bind               = bind,
        power_saver_toggle = power_saver_toggle,
        editor_command     = editor_command,
        editor_rule_key    = editor_rule_key,
    },
}
