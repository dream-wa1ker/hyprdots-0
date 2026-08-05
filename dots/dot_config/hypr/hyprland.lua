-- ~/.config/hypr/hyprland.lua
--
-- Orchestrator only. No config logic lives here — it loads bootstrap,
-- then requires every module through boot.safe_require so a broken module
-- logs+notifies instead of killing everything that loads after it.
-- (No scheme/theming system — colors are hardcoded per-module, matching
-- the new config's actual palette.)

local home = os.getenv("HOME")
local hypr = home .. "/.config/hypr"

-- This ONE require is intentionally NOT wrapped in pcall: if bootstrap
-- itself fails to load, nothing downstream can help anyway, and Hyprland's
-- own emergency binds (SUPER+Q/R/M) are the fallback at that point.
local boot = require("core.bootstrap")

local function maybe_create(file, content)
    local f = io.open(file)
    if f then f:close(); return end
    f = io.open(file, "w")
    if f then
        if content then f:write(content) end
        f:close()
    end
end

local function maybe_copy(src, dst)
    local out = io.open(dst)
    if out then out:close(); return end
    local input = io.open(src, "r")
    if not input then return end
    out = io.open(dst, "w")
    if out then
        out:write(input:read("*a"))
        out:close()
    end
    input:close()
end


-- Default monitor conf
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1,
})

-- Core modules, in dependency order (see the plan from earlier in this thread).
-- Each goes through safe_require: a failure here logs + notifies but does not
-- prevent modules further down the list — critically, keybinds.lua still
-- loads even if, say, rules.lua has a typo.
local modules = {
    "hyprland.env",
    "hyprland.general",
    "hyprland.input",
    "hyprland.misc",
    "hyprland.animations",
    "hyprland.decoration",
    "hyprland.group",
    "hyprland.functions",
    "hyprland.execs",
    "hyprland.rules",
    "hyprland.gestures",
    "hyprland.keybinds",
}

for _, name in ipairs(modules) do
    boot.safe_require(name)
end


