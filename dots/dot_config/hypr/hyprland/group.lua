-- ~/.config/hypr/hyprland/group.lua
local vars = require("variables")

-- No scheme system in new — these are new's actual colors:
-- accent teal (0DB7D4), dark bg for text-on-accent (131315),
-- inactive-border hex as outline (1b1b1d), active-border hex as secondary (474648)

hl.config({
    group = {
        col = {
            border_active          = vars.activeWindowBorderColour,
            border_inactive        = vars.inactiveWindowBorderColour,
            border_locked_active   = vars.activeWindowBorderColour,
            border_locked_inactive = vars.inactiveWindowBorderColour,
        },
        groupbar = {
            font_family               = "JetBrains Mono NF", -- ttf-jetbrains-mono-nerd installed
            font_size                 = 15,
            gradients                 = true,
            gradient_round_only_edges = false,
            gradient_rounding         = 5,
            height                    = 25,
            indicator_height          = 0,
            gaps_in                   = 3,
            gaps_out                  = 3,
            text_color                = "rgb(131315)",
            col = {
                active          = "rgba(0DB7D4d4)",
                inactive        = "rgba(1b1b1dd4)",
                locked_active   = "rgba(0DB7D4d4)",
                locked_inactive = "rgba(474648d4)",
            },
        },
    },
})
