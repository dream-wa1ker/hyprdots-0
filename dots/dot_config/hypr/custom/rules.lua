-- ~/.config/hypr/custom/rules.lua
-- dream-wa1ker
--
-- PURPOSE   Window, workspace and layer (bars, launchers, notifications) rules, applied
--           after the defaults in hyprland/rules.lua.
-- RETURNS   { window = { ... }, workspace = { ... }, layer = { ... } }; omit any part you don't use.
-- LOADED    After hyprland/rules.lua; a later rule wins over an earlier one for the same effect.
--
-- WINDOW RULE   { match = { ... }, effect = value, ... }
--   Find class/title of a window:  hyprctl clients | grep -E "class|title"
--   match   class, initial_class, title, initial_title (regular expressions), float,
--           xwayland, workspace, tag
--   effects float, tile, size, move, center, pin, workspace, tag, opaque, no_shadow,
--           no_blur, no_dim, rounding, immediate, keep_aspect_ratio, no_initial_focus
--           Sizes accept expressions: size = { "(monitor_w*0.5)", "(monitor_h*0.6)" }
--   Prefer `class` over `title`: any application can set its own title, so a rule on a
--   title (especially `pin` or `float`) can be triggered by a window you didn't mean.
--
-- WORKSPACE RULE  { workspace = "special:name", layout = "scrolling", gaps_out = 20, ... }
-- LAYER RULE      { match = { namespace = "regex" }, blur = true, no_anim = true, ... }
--                 List namespaces with: hyprctl layers

return {
    -- Active ---------------------------------------------------------------------
    -- special workspace: scrolling layout, outer gap 20
    workspace = {
        {
            workspace = "special:special",
            layout = "scrolling",
            layout_opts = {
                direction = "right",
            },
            gaps_out = 20,
        },
    },

    window = {
        -- windows on the special workspace take half of the width
        {
            match = {
                workspace = "special:special",
            },
            scrolling_width = 0.5,
        },

        -- Examples: remove the leading `--` to enable ----------------------------
        -- Always float a program:
        -- { match = { class = "^(pavucontrol)$" }, float = true },
        --
        -- VM lab on its own special workspace (check the real class with hyprctl clients):
        -- { match = { class = "VirtualBox Machine" }, workspace = "special:lab" },
    },

    layer = {
        -- { match = { namespace = "my-overlay" }, no_anim = true },
    },
}
