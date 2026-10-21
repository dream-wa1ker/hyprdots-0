-- ~/.config/hypr/custom/gestures.lua
-- dream-wa1ker
--
-- PURPOSE   Touchpad gestures.
-- RETURNS   { config = { gestures = { ... } }, gestures = { { fingers = ..., direction = ..., action = ... } } }
-- LOADED    After hyprland/gestures.lua; gestures listed here are added to the defaults.
-- ACTIONS   "workspace", "special", "fullscreen", or a Lua function.
--           Finger counts used by default: 3 (workspaces, special, fullscreen), 4 (sleep).

return {
    -- config = {
    --     gestures = { workspace_swipe_distance = 500 },
    -- },

    -- gestures = {
    --     { fingers = 4, direction = "up", action = function() hl.exec_cmd("pavucontrol") end },
    -- },
}
