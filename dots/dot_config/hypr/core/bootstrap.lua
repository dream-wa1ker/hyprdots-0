-- ~/.config/hypr/core/bootstrap.lua
-- dream-wa1ker

local M = {}


function M.safe_require(name)
    local ok, mod_or_err = pcall(require, name)

    if not ok then
        print(("[Hyprland config] Failed to load '%s': %s")
            :format(name, tostring(mod_or_err)))

        hl.notification.create({
            text = "Hyprland config: '" .. name .. "' failed to load",
            duration = 6000,
            icon = "warning",
        })

        return nil
    end

    return mod_or_err
end

function M.safe_call(fn, label)
    return function(...)
        local ok, result = pcall(fn, ...)

        if not ok then
            print(("[Hyprland config] %s failed: %s")
                :format(label or "callback", tostring(result)))
            return nil, result
        end

        return result
    end
end

function M.deep_merge(base, overrides)
    for k, v in pairs(overrides or {}) do
        if type(v) == "table" and type(base[k]) == "table" then
            M.deep_merge(base[k], v)
        else
            base[k] = v
        end
    end
    return base
end


function M.apply_all(fn, specs, label)
    for i, spec in ipairs(specs) do
        local ok, err = pcall(fn, spec)

        if not ok then
            print(("[Hyprland config] %s entry %d failed: %s")
                :format(label or "configuration", i, tostring(err)))
        end
    end
end

return M
