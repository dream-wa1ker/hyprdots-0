-- ~/.config/hypr/hyprland/general.lua
local vars = require("variables")

hl.config({
    general = {
        layout        = "dwindle",
        allow_tearing = false, -- lets the `immediate` window rule work if you add one later

        gaps_workspaces = vars.workspaceGaps,
        gaps_in         = vars.windowGapsIn,
        gaps_out        = vars.windowGapsOut,
        border_size     = vars.windowBorderSize,

        col = {
            active_border   = vars.activeWindowBorderColour,
            inactive_border = vars.inactiveWindowBorderColour,
        },
    },

    dwindle = {
        preserve_split = true,
        smart_split    = false,
        smart_resizing = true,
    },
})
