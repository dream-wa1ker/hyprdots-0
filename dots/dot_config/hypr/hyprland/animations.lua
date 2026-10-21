-- ~/.config/hypr/hyprland/animations.lua
-- dream-wa1ker
-- Curves and animations as data. ipairs over arrays keeps the order fixed.

hl.config({
    animations = {
        enabled = true,
    },
})

-- { name, control point 1, control point 2 }
local curves = {
    { "emphasizedDecel", { 0.05, 0.7  }, { 0.1, 1    } },
    { "emphasizedAccel", { 0.3,  0    }, { 0.8, 0.15 } },
    { "standardDecel",   { 0,    0    }, { 0,   1    } },
    { "menu_decel",      { 0.1,  1    }, { 0,   1    } },
    { "menu_accel",      { 0.52, 0.03 }, { 0.72, 0.08 } },
    { "stall",           { 1,   -0.1  }, { 0.7, 0.85 } },
}

for _, c in ipairs(curves) do
    hl.curve(c[1], { type = "bezier", points = { c[2], c[3] } })
end

-- Leaves not listed here keep Hyprland's defaults.
local animations = {
    -- windows
    { leaf = "windowsIn",  speed = 5,  bezier = "emphasizedDecel" },
    { leaf = "windowsOut", speed = 3,  bezier = "emphasizedAccel" },
    { leaf = "fadeIn",     speed = 3,  bezier = "emphasizedDecel" },
    { leaf = "fadeOut",    speed = 2,  bezier = "emphasizedDecel" },
    { leaf = "windowsMove", speed = 3, bezier = "emphasizedDecel", style = "slide" },
    { leaf = "border",     speed = 10, bezier = "emphasizedDecel" },

    -- layers (bars, launchers, notifications)
    { leaf = "layersIn",      speed = 2.7, bezier = "emphasizedDecel", style = "popin 93%" },
    { leaf = "layersOut",     speed = 2.4, bezier = "menu_accel",      style = "popin 94%" },
    { leaf = "fadeLayersIn",  speed = 0.5, bezier = "menu_decel" },
    { leaf = "fadeLayersOut", speed = 2.7, bezier = "stall" },

    -- workspaces
    { leaf = "workspaces",          speed = 7,   bezier = "menu_decel",      style = "slide" },
    { leaf = "specialWorkspaceIn",  speed = 2.8, bezier = "emphasizedDecel", style = "slidevert" },
    { leaf = "specialWorkspaceOut", speed = 1.2, bezier = "emphasizedAccel", style = "slidevert" },

    -- zoom
    { leaf = "zoomFactor", speed = 3, bezier = "standardDecel" },
}

for _, a in ipairs(animations) do
    hl.animation({
        leaf    = a.leaf,
        enabled = true,
        speed   = a.speed,
        bezier  = a.bezier,
        style   = a.style,   -- nil for entries without a style
    })
end
