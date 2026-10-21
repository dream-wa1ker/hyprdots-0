-- ~/.config/hypr/hyprland/lib/init.lua
-- dream-wa1ker
-- Small filesystem helpers. Returns a table; defines no globals.

local M = {}

function M.is_file_exists(path)
    local f = io.open(path, "r")
    if f then
        f:close()
        return true
    end
    return false
end

-- Quote a string for /bin/sh: wrap in single quotes, turn each ' into '\''.
-- Anything that reaches os.execute must go through this; unquoted input
-- is how command injection happens.
function M.shell_quote(s)
    return "'" .. (tostring(s):gsub("'", "'\\''")) .. "'"
end

-- Standard Lua has no mkdir, so this is the one place we shell out.
function M.ensure_dir(path)
    local ok = os.execute("mkdir -p -- " .. M.shell_quote(path))
    return ok == true or ok == 0   -- 5.2+ returns true, 5.1 returns 0
end

-- Create a file only if it does not exist. Never overwrites.
function M.write_file_if_missing(path, content)
    if M.is_file_exists(path) then
        return false
    end
    local f, err = io.open(path, "w")
    if not f then
        return false, err
    end
    f:write(content)
    f:close()
    return true
end

return M
