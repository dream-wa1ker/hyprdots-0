-- ~/.config/hypr/custom/general.lua
-- dream-wa1ker
--
-- PURPOSE   Layout, gaps, borders. Also the `dwindle` and `scrolling` layout options.
-- RETURNS   A table in hl.config format: { section = { option = value } }.
--           ({ config = { ... } } is also accepted.)
-- LOADED    After hyprland/general.lua. Only the options you list change; the rest keep
--           their default.
-- TIP       Gaps and border size have variables (windowGapsIn, windowGapsOut,
--           windowBorderSize): set those in custom/variables.lua instead.

return {
    -- general = {
    --     layout           = "scrolling",  -- "dwindle", "master", "scrolling", "monocle"
    --     resize_on_border = true,         -- drag window borders to resize
    -- },
    -- dwindle = {
    --     preserve_split = true,
    -- },
    -- scrolling = {
    --     column_width = 0.8,
    -- },
}
