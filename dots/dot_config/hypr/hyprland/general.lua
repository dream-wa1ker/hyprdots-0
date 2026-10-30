-- ~/.config/hypr/hyprland/general.lua
-- dream-wa1ker

local vars = require("hyprland.variables")

hl.config({
    general = {
        layout        = "dwindle",
        allow_tearing = false, -- disable tearing globally, including windows with an immediate rule

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


-- case for noctalia; pre number workspaces.
-- if needed, can be created more than that; 
for i = 1, 5 do
    hl.workspace_rule({
        workspace = tostring(i),
        persistent = true,
    })
end



