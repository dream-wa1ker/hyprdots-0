-- ~/.config/hypr/hyprland/lib/create_custom_config.lua
-- dream-wa1ker
-- Creates empty override stubs in custom/ so there is always a file to edit.
-- Existing files are never touched.

local lib = require("hyprland.lib")

local M = {}

local STUB = [[
-- ~/.config/hypr/custom/%s.lua
-- Your overrides for the '%s' module. This file is never overwritten.
-- The expected return value is documented at the bottom of ~/.config/hypr/hyprland.lua.
return {}
]]

-- Returns how many stub files were created.
function M.ensure(customDir, names)
    lib.ensure_dir(customDir)
    local created = 0
    for _, name in ipairs(names) do
        local path = customDir .. "/" .. name .. ".lua"
        if lib.write_file_if_missing(path, STUB:format(name, name)) then
            created = created + 1
        end
    end
    return created
end

return M
