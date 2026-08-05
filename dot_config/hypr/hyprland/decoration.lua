-- ~/.config/hypr/hyprland/decoration.lua
local vars = require("variables")

hl.config({
    decoration = {
        rounding = vars.windowRounding,

        -- Universal transparency: applies to every window unless a window
        -- rule overrides it (opaque apps do this in rules.lua via opaque=true,
        -- which is not the same knob — opaque bypasses these entirely rather
        -- than needing an opacity value to fight against).
        active_opacity     = vars.windowOpacity,
        inactive_opacity    = vars.windowOpacity,
        fullscreen_opacity  = 1.0, -- fullscreen content (video, games) stays fully solid

        -- Universal blur: applies to every window's background by default.
        blur = {
            enabled           = vars.blurEnabled,
            xray              = vars.blurXray,
            special           = vars.blurSpecialWs,
            ignore_opacity    = true, -- blur still renders under transparent windows
            new_optimizations = true,
            popups            = vars.blurPopups,
            input_methods     = vars.blurInputMethods,
            size              = vars.blurSize,
            passes            = vars.blurPasses,
        },

        shadow = {
            enabled      = vars.shadowEnabled,
            range        = vars.shadowRange,
            render_power = vars.shadowRenderPower,
            color        = vars.shadowColour,
        },
    },
})
