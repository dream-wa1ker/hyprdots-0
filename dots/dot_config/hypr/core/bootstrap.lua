-- ~/.config/hypr/core/bootstrap.lua
--

local M = {}

function M.safe_require(name)
    local ok, mod_or_err = pcall(require, name)
    if not ok then
        hl.notification.create({
            text     = "Hyprland config: '" .. name .. "' failed to load",
            duration = 6000,
            icon     = "warning",
        })
        return nil
    end
    return mod_or_err
end

function M.safe_call(fn, label)
    return function(...)
        local ok, err = pcall(fn, ...)
        if not ok then
        end
        return err
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
        end
    end
end

return M
