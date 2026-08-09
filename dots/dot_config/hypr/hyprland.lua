-- ~/.config/hypr/hyprland.lua

local home = os.getenv("HOME")
local hypr = home .. "/.config/hypr"

local boot = require("core.bootstrap")

-- Internal libraries and services
local lib = boot.safe_require("hyprland.lib")
boot.safe_require("hyprland.services")

-- Safe file exist check (checks module table, global scope, or io.open)
local function is_file_exists(path)
    if type(lib) == "table" and type(lib.is_file_exists) == "function" then
        return lib.is_file_exists(path)
    elseif type(_G.is_file_exists) == "function" then
        return _G.is_file_exists(path)
    end
    local f = io.open(path, "r")
    if f then
        f:close()
        return true
    end
    return false
end

local function maybe_create(file, content)
    if is_file_exists(file) then return end
    local f = io.open(file, "w")
    if f then
        if content then f:write(content) end
        f:close()
    end
end

local function maybe_copy(src, dst)
    if is_file_exists(dst) then return end
    local input = io.open(src, "r")
    if not input then return end
    local out = io.open(dst, "w")
    if out then
        out:write(input:read("*a"))
        out:close()
    end
    input:close()
end

-- Default monitor configuration
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1,
})

-- Core modules to load in dependency order
local modules = {
    "env",
    "general",
    "input",
    "misc",
    "animations",
    "decoration",
    "group",
    "functions",
    "execs",
    "rules",
    "gestures",
    "colors",
    "keybinds",
}

-- Load core modules via boot.safe_require
for _, name in ipairs(modules) do
    boot.safe_require("hyprland." .. name)
end

-- Load custom user overrides (if present in ~/.config/hypr/custom/)
for _, name in ipairs(modules) do
    local custom_file = hypr .. "/custom/" .. name .. ".lua"
    if is_file_exists(custom_file) then
        boot.safe_require("custom." .. name)
    end
end

-- Dynamic display and workspace configurations (e.g. nwg-displays)
if is_file_exists(hypr .. "/workspaces.lua") then
    boot.safe_require("workspaces")
end

if is_file_exists(hypr .. "/monitors.lua") then
    boot.safe_require("monitors")
end

-- Shell overrides
boot.safe_require("hyprland.shellOverrides.main")
