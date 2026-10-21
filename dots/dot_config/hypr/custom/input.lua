-- ~/.config/hypr/custom/input.lua
-- dream-wa1ker
--
-- PURPOSE   Keyboard, mouse, touchpad and cursor behaviour.
-- RETURNS   A table in hl.config format: { section = { option = value } }.
--           ({ config = { ... } } is also accepted.)
-- LOADED    After hyprland/input.lua; only the options you list change.
-- NOTES     Option names follow the Hyprland wiki (Variables > Input). `hyprctl reload`
--           prints a notification for a name Hyprland does not know.

return {
    -- input = {
    --     kb_layout    = "us",
    --     kb_options   = "caps:escape",  -- Caps Lock becomes Escape (handy in nvim)
    --     follow_mouse = 1,              -- focus follows the mouse
    --     repeat_delay = 250,
    --     repeat_rate  = 35,
    --     touchpad = {
    --         natural_scroll = true,
    --     },
    -- },
    -- cursor = {
    --     hide_on_key_press = true,
    -- },
}
