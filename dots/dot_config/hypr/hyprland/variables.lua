-- ~/.config/hypr/hyprland/variables.lua
-- dream-wa1ker
-- Application and desktop settings. Keybindings live entirely in the keybinds files.

return {
    ------------------
    ---- HYPRLAND ----
    ------------------

    -- Each app is defined once: command, classes, terminal wrapping, and geometry.
    -- command is a trusted shell command; terminal wraps it in apps.terminal.
    -- exec_args is the terminal's argument separator (e.g. {"-e"} or {"--"}).
    -- Geometry affects floating launches/toggles; auto_float also creates a native rule.
    -- Rule-only records may omit command. Classes are exact strings, not regexes.
    apps = {
        terminal = { command = "kitty", classes = { "kitty" }, exec_args = { "-e" } },
        browser = { command = "chromium", classes = { "chromium" } },
        editor = { command = "nvim", terminal = true },
        fileManager = {
            command = "dolphin", classes = { "org.kde.dolphin" },
            geometry = { w = 1000, h = 600, x = 100, y = 100 },
        },
        audioMixer = {
            command = "pavucontrol", classes = { "org.pulseaudio.pavucontrol", "pavucontrol" },
            geometry = { wp = 0.45, hp = 0.45 }, auto_float = true,
        },
        bluetooth = {
            command = "blueman-manager", classes = { "blueman-manager" },
            geometry = { wp = 0.6, hp = 0.7 }, auto_float = true,
        },
        appearance = {
            command = "nwg-look", classes = { "nwg-look" },
            geometry = { wp = 0.5, hp = 0.6 }, auto_float = true,
        },
        partitionManager = {
            command = "partitionmanager", classes = { "org.kde.partitionmanager" },
            geometry = { wp = 0.7, hp = 0.8 }, auto_float = true,
        },
        tuba = {
            command = "tuba", classes = { "dev.geopjr.Tuba" },
            geometry = { wp = 0.7, hp = 0.8 }, auto_float = true,
        },
        networkEditor = {
            command = "nm-connection-editor", classes = { "nm-connection-editor" },
            geometry = { wp = 0.45, hp = 0.45 }, auto_float = true,
        },
        kdePortal = {
            classes = { "org.freedesktop.impl.portal.desktop.kde" },
            geometry = { wp = 0.6, hp = 0.65 }, auto_float = true,
        },
        zotero = {
            command = "zotero", classes = { "Zotero" },
            geometry = { wp = 0.45, hp = 0.45 }, auto_float = true,
        },
        noctalia = {
            classes = { "dev.noctalia.Noctalia" },
            geometry = { w = 1080, h = 920 }, auto_float = true,
        },
        colorPicker = { command = "hyprpicker -a" },
    },

    -- Touchpad / gestures
    touchpadDisableTyping    = true,
    touchpadScrollFactor     = 0.3,
    gestureFingers           = 3,
    workspaceSwipeFingers    = 3,
    gestureFingersMore       = 4,
    gestureFingersFullscreen = 3,

    -- Blur
    blurEnabled      = true,
    blurSpecialWs    = false,
    blurPopups       = true,
    blurInputMethods = true,
    blurSize         = 8,
    blurPasses       = 3,
    blurXray         = false,

    -- Shadow
    shadowEnabled     = true,
    shadowRange       = 15,
    shadowRenderPower = 4,
    shadowColour      = "rgba(00000020)",

    -- Gaps
    workspaceGaps       = 20,
    windowGapsIn        = 5,
    windowGapsOut       = 10,
    singleWindowGapsOut = 10,

    -- Window styling
    windowOpacity   = 0.85,
    windowRounding  = 12,
    windowBorderSize = 1,

    -- Miscellaneous behavior
    volumeStep      = 10,
    volumeMax       = 100,
    cursorTheme     = "Bibata-Modern-Classic",
    cursorSize      = 14,
    sleepGestureCmd = "systemctl suspend-then-hibernate",
    shell           = "noctalia", -- executable name or path, without arguments
    autostartKdeConnect = true, -- launch the indicator at session startup

    -- Fallback geometry for applications without their own specification.
    defaultRule = { wp = 0.55, hp = 0.6 },
}
