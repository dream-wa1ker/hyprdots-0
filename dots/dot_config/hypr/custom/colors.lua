-- ~/.config/hypr/custom/colors.lua
-- dream-wa1ker
--
-- PURPOSE   Colour overrides that win over Noctalia's generated theme, including the
--           per-profile overrides of ~/.dotfiles/profiles/<name>.
-- RETURNS   A table in hl.config format: { section = { col = { ... } } }.
--           ({ config = { ... } } is also accepted.)
-- LOADED    LAST, after noctalia.apply_theme(), so a regenerated theme never wins.
-- PROFILES  scripts/profile-switch writes the active profile name to
--           ~/.dotfiles/profiles/.current BEFORE it reloads, so this file always sees
--           the new profile. A profile without an entry in PROFILE_OVERRIDES gets
--           no override, which keeps it identical to the Noctalia theme.
-- ADD ONE   PROFILE_OVERRIDES.<name> = function(c) return { ... } end
--           `c` is the colour table exported by ~/.config/hypr/noctalia.lua
--           (primary, surface, on_surface, secondary, on_secondary, error, on_error).
--           Return nil to apply nothing.
-- FORMAT    "rgba(RRGGBBAA)" or "rgb(RRGGBB)".

local home = os.getenv("HOME")
if not home then
    return {}
end

local PROFILE_FILE = home .. "/.dotfiles/profiles/.current"

-- Name of the active profile, or nil when the file is missing or malformed.
local function current_profile()
    local f = io.open(PROFILE_FILE, "r")
    if not f then
        return nil
    end
    local line = f:read("*l")
    f:close()
    if type(line) ~= "string" then
        return nil
    end
    line = line:match("^%s*(.-)%s*$")
    return line:match("^[%w][%w._-]*$") and line or nil
end

-- Noctalia's generated module (already loaded by hyprland.lua; require is cached).
local ok, noctalia = pcall(require, "noctalia")
if not ok or type(noctalia) ~= "table" or type(noctalia.colors) ~= "table" then
    return {}
end

local PROFILE_OVERRIDES = {
    -- Pure-black monochrome theme: a translucent white active border. Only applied
    -- while the generated primary colour really is white, so another wallpaper scheme
    -- is never forced into this look.
    black = function(c)
        if c.primary ~= "rgb(ffffff)" then
            return nil
        end
        return {
            general = {
                col = {
                    active_border = "rgba(ffffff60)",
                    inactive_border = c.on_secondary,
                },
            },
        }
    end,
}

local override = PROFILE_OVERRIDES[current_profile()]
return override and override(noctalia.colors) or {}
