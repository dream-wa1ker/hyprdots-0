-- ~/.config/hypr/hyprland/general.lua
-- dream-wa1ker

local vars = require("hyprland.variables")

hl.config({
    general = {
        layout        = "dwindle",
        allow_tearing = false, -- lets the `immediate` window rule work if you add one later

        gaps_workspaces = vars.workspaceGaps,
        gaps_in         = vars.windowGapsIn,
        gaps_out        = vars.windowGapsOut,
        border_size     = vars.windowBorderSize,

    },

    dwindle = {
        preserve_split = true,
        smart_split    = false,
        smart_resizing = true,
    },

    scrolling = {
        direction = "down",
        focus_fit_method = 1,
        column_width = 0.8,
    },
})
