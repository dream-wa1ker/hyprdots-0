
local vars = require("hyprland.variables")

local shell = vars.shell or "illogical-impulse"

local shellModules = {
    ["illogical-impulse"] = "hyprland.keybinds.illogical-impulse",
    ["noctalia"] = "hyprland.keybinds.noctalia",
}

-- Load shared bindings.
require("hyprland.keybinds.shared")

-- Load only the selected shell's bindings.
local module = shellModules[shell]

if module then
    require(module)
else
    error("Unknown shell: " .. tostring(shell))
end

