-- ~/.config/hypr/custom/env.lua
-- dream-wa1ker
--
-- PURPOSE   Extra environment variables for every program Hyprland starts.
-- RETURNS   { NAME = "value", ... }   ({ env = { ... } } is also accepted)
-- LOADED    After hyprland/env.lua, so a name set here wins over the default.
-- NOTES     Use strings for values. Never put tokens, passwords or API keys here: every
--           program inherits these, and this file lives in your dotfiles repository.

return {
    -- MOZ_ENABLE_WAYLAND = "1",
    -- QT_SCALE_FACTOR    = "1.25",
}
