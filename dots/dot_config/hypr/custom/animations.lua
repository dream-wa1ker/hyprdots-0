-- ~/.config/hypr/custom/animations.lua
-- dream-wa1ker
--
-- PURPOSE   Change animation speed, curves and styles.
-- RETURNS   { config = { ... }, curves = { ... }, animations = { ... } }; omit unused parts.
-- LOADED    After hyprland/animations.lua. An animation for a `leaf` that is already
--           defined replaces the default one.
-- CURVES    name -> { type = "bezier", points = { {x1, y1}, {x2, y2} } }
--           Defaults you can reuse: emphasizedDecel, emphasizedAccel, standardDecel,
--           menu_decel, menu_accel, stall.
-- LEAVES    windowsIn, windowsOut, windowsMove, border, fadeIn, fadeOut, layersIn, layersOut,
--           workspaces, specialWorkspaceIn, specialWorkspaceOut, zoomFactor ...
--           (full list: Hyprland wiki > Animations)
-- SPEED     Higher is slower; the unit is 100 ms.

return {
    -- Turn every animation off (frees the GPU on battery):
    -- config = { animations = { enabled = false } },

    -- curves = {
    --     snappy = { type = "bezier", points = { { 0.2, 0.9 }, { 0.1, 1.0 } } },
    -- },

    -- animations = {
    --     { leaf = "windowsIn", enabled = true, speed = 3, bezier = "snappy" },
    -- },
}
