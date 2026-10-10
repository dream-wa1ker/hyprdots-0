
-- ~/.config/hypr/hyprland/keybinds/noctalia.lua
-- Noctalia v5+ shell-specific keybindings

local vars = require("hyprland.variables")

local function noctalia(command)
    return hl.dsp.exec_cmd("noctalia msg " .. command)
end

------------------------------------------------------------------
-- Launcher / search
------------------------------------------------------------------

-- Original: Quickshell search toggle
hl.bind("SUPER + SUPER_L",
    noctalia("panel-toggle launcher"),
    { description = "Noctalia: Toggle Launcher / Search" })

-- Noctalia has a window switcher, but not the same workspace overview.
hl.bind("SUPER + Tab",
    noctalia("window-switcher hold"),
    { description = "Noctalia: Window Switcher" })

------------------------------------------------------------------
-- Session panel
------------------------------------------------------------------

hl.bind(vars.kbSession,
    noctalia("panel-toggle session"),
    { description = "Noctalia: Toggle Session Panel" })

-- Lock the session directly.
hl.bind("SUPER + L",
    noctalia("session lock"),
    { description = "Noctalia: Lock Screen" })

------------------------------------------------------------------
-- Control Center / settings
------------------------------------------------------------------

-- Replaces the general left sidebar with Noctalia's Control Center.
hl.bind("SUPER + A",
    noctalia("panel-toggle control-center"),
    { description = "Noctalia: Toggle Control Center" })

-- Open Control Center on its notifications tab.
hl.bind("SUPER + N",
    noctalia("panel-toggle control-center notifications"),
    { description = "Noctalia: Control Center Notifications" })

-- Open Control Center on its media tab.
hl.bind("SUPER + M",
    noctalia("panel-toggle control-center media"),
    { description = "Noctalia: Control Center Media" })

-- Settings replaces the old detached sidebar / configuration access.
hl.bind("SUPER + ALT + A",
    noctalia("settings-toggle"),
    { description = "Noctalia: Toggle Settings" })

-- Open the launcher's provider overview, similar to a cheatsheet.
hl.bind("SUPER + Slash",
    noctalia('panel-toggle launcher "/"'),
    { description = "Noctalia: Launcher Provider Overview" })

------------------------------------------------------------------
-- Bar
------------------------------------------------------------------

hl.bind("SUPER + J",
    noctalia("bar-toggle"),
    { description = "Noctalia: Toggle Bar" })

------------------------------------------------------------------
-- Wallpaper
------------------------------------------------------------------

hl.bind("SUPER + W",
    noctalia("panel-toggle wallpaper"),
    { description = "Noctalia: Toggle Wallpaper Picker" })

hl.bind("CTRL + SUPER + ALT + T",
    noctalia("wallpaper-random"),
    { description = "Noctalia: Set Random Wallpaper" })

------------------------------------------------------------------
-- Clipboard / emoji
------------------------------------------------------------------

hl.bind("SUPER + V",
    noctalia("panel-toggle clipboard"),
    { description = "Noctalia: Clipboard History" })

-- Noctalia v5's built-in emoji provider uses the /emo prefix.
hl.bind("SUPER + Period",
    noctalia('panel-toggle launcher "/emo "'),
    { description = "Noctalia: Emoji Picker" })

------------------------------------------------------------------
-- Screenshots
------------------------------------------------------------------

hl.bind("SUPER + SHIFT + S",
    noctalia("screenshot-region"),
    { description = "Noctalia: Region Screenshot" })

------------------------------------------------------------------
-- Reload configuration
------------------------------------------------------------------

-- Reload Noctalia configuration without killing the shell process.
hl.bind("CTRL + SUPER + R",
    noctalia("config-reload"),
    { release = true, description = "Noctalia: Reload Configuration" })

------------------------------------------------------------------
-- No direct Noctalia v5 equivalent
------------------------------------------------------------------

-- View keybindings;
-- Noctalia keybindings cheatsheet
hl.bind("SUPER + Slash",
    hl.dsp.exec_cmd("noctalia msg panel-toggle kenn/keybind-cheatsheet:cheatsheet"),
    { description = "Noctalia: Keybindings Cheatsheet" })

-- SUPER + K:
-- Noctalia does not document a built-in on-screen keyboard panel.
-- Configure an external on-screen keyboard separately if required.


-- CTRL + SUPER + P:
-- No direct equivalent to the old panel-family cycling action.


-- SUPER + SHIFT + X:
-- No built-in OCR action is documented in Noctalia IPC, but it is in commuity plugin; yay;;

-- OCR
hl.bind("SUPER + X",
    hl.dsp.exec_cmd("noctalia msg plugin fel/ocr:ocr all ocr-region"),
    { description = "Noctalia: OCR Selected Region" })

hl.bind("SUPER + SHIFT + X",
    hl.dsp.exec_cmd("noctalia msg plugin fel/ocr:ocr all ocr-screen"),
    { description = "Noctalia: OCR Full Screen" })

-- SUPER + ALT + T:
-- No built-in screen-translation action is documented in Noctalia IPC.

-- SUPER + CTRL + R / SUPER + ALT + R:
-- The old region-recording actions require a separate recording tool.

-- SUPER + R / SUPER + SHIFT + R:
-- Fullscreen recording must be configured separately. The old script
-- under ~/.config/quickshell/ should not be assumed to work with Noctalia.

-- CTRL + SUPER + ALT + T is already assigned to random wallpaper above.
-- The old panel-family cycling shortcut is intentionally not duplicated.




-- Alternatives for  Super + G
-- SUPER + G:
-- No direct equivalent to the old Quickshell quick-overlays toggle.


-- Frozen screenshot editor
hl.bind("SUPER + SHIFT + G",
    hl.dsp.exec_cmd("noctalia msg screenshot-annotate"),
    { description = "Noctalia: Screenshot Annotation" })

-- Live desktop annotation
hl.bind("SUPER + G",
    hl.dsp.exec_cmd("noctalia msg annotate"),
    { description = "Noctalia: Live Screen Annotation" })



-- Open the Settings App
hl.bind("SUPER + I",
    hl.dsp.exec_cmd("noctalia msg settings-toggle"),
    { description = "Noctalia: Toggle Settings" })

-- Arch Updater panel (replaces OSK)
hl.bind("SUPER + K",
    hl.dsp.exec_cmd("noctalia msg panel-toggle yuuto/arch-updater:panel"),
    { description = "Noctalia: Arch Updater" })

hl.bind("SUPER + F",
    hl.dsp.exec_cmd("noctalia msg panel-toggle thepunkoff/pomodoro:panel"), 
    { description = "Noctalia : Pomodoro Focus Timer"})


