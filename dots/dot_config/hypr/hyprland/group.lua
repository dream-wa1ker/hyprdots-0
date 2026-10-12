-- ~/.config/hypr/hyprland/group.lua
-- dream-wa1ker

local vars = require("hyprland.variables")

-- No scheme system in new — these are new's actual colors:
-- accent teal (0DB7D4), dark bg for text-on-accent (131315),
-- inactive-border hex as outline (1b1b1d), active-border hex as secondary (474648)

hl.config({
    group = {
         groupbar = {
            font_family               = "JetBrains Mono NF", -- ttf-jetbrains-mono-nerd installed
            font_size                 = 0,
            gradients                 = true,
            gradient_round_only_edges = false,
            gradient_rounding         = 5,
            height                    = 5,
            indicator_height          = 0,
            gaps_in                   = 2,
            gaps_out                  = 2,
          },
    },
})
