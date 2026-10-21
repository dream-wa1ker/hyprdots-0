-- ~/.config/hypr/custom/misc.lua
-- dream-wa1ker
--
-- PURPOSE   Miscellaneous behaviour: focus, power saving, terminal swallowing, session lock.
-- RETURNS   A table in hl.config format: { section = { option = value } }.
--           ({ config = { ... } } is also accepted.)
-- LOADED    After hyprland/misc.lua; only the options you list change.
-- SECURITY  `focus_on_activate = true` (the default) lets any window pull focus to itself
--           while you type; a hostile window could capture a password that way. Setting it
--           to false is safer at the cost of convenience.

return {
    -- misc = {
    --     vfr                = true,            -- redraw only when needed (battery)
    --     enable_swallow     = true,            -- a GUI app launched from a terminal replaces it
    --     swallow_regex      = "^(kitty)$",     -- class of the terminal that may be swallowed
    --     focus_on_activate  = false,
    -- },
}
