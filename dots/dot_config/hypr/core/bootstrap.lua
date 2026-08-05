-- ~/.config/hypr/core/bootstrap.lua
--
-- Loaded first, by nothing but itself. Every other module goes through
-- M.safe_require instead of raw `require`, so one broken file logs a
-- notification instead of silently killing every module that loads after it.

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

-- Wrap a function that runs later (keybind, gesture, event callback) so a
-- runtime bug inside it logs instead of erroring mid-interaction.
function M.safe_call(fn, label)
    return function(...)
        local ok, err = pcall(fn, ...)
        if not ok then
        end
        return err
    end
end

-- Recursive merge: overrides win, nested tables merge instead of replacing.
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

-- Apply a list of {fn, spec} pairs through pcall, logging failures by index
-- instead of aborting the whole batch. Used later by rules.lua/keybinds.lua
-- for the declarative table+applier pattern.
function M.apply_all(fn, specs, label)
    for i, spec in ipairs(specs) do
        local ok, err = pcall(fn, spec)
        if not ok then
        end
    end
end

return M
