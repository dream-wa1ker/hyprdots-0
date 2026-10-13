-- ~/.config/hypr/custom/variables.lua
-- dream-wa1ker
-- Central configuration for applications, behavior, and every default keybinding. : Overrides

return {
    -- Custom Window appearance
    -- Check the name of the variables in hyprland/variables, override them here.
    windowOpacity  = 0.85,
    windowRounding = 15,
    editor = "nvim",
    -- modified the default terminal
    
    ------------------
    ---- KEYBINDS ----
    ------------------
    -- Every literal default shortcut lives here. Actions remain in keybinds.lua.
    keybinds = {
        -- Overrides the already existing keybindings in default
        --  NOTE : This config comes with duplicate detection in keybindings; 

        -- browser = "SUPER + SHIFT + B",
        -- duplicates with the SUPER + SHIF + B = browser in float mode in default, change that too; 
        -- floatingBrowser = "SUPER + B",

        -- or you can override the action : declare a keybind here first.
        -- this overlaps the settings shortcut.
        -- customLaunchTerminal = "SUPER + I", 

        -- Keep the custom specfic keybindings here; 
        customEditKeybinds = "CTRL + SUPER + ALT + Slash",
        customCloseWindow  = "SUPER + Q",
        customTest = "SUPER + ALT + I",
    },
}
