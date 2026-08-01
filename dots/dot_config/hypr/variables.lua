-- ~/.config/hypr/variables.lua
local scheme = require("scheme.current")

return {
    ------------------
    ---- HYPRLAND ----
    ------------------

    -- Apps
    -- NOTE: you have BOTH thunar and dolphin, and BOTH nvim and zed installed.
    -- Defaulting to thunar/nvim (matches your old setup) — say the word if
    -- you actually want dolphin/zed as primary now, it's a one-line change.
    terminal      = "kitty",
    browser       = "zen-browser",   -- zen-browser-bin's desktop entry launches this binary name
    editor        = "nvim",
    fileExplorer  = "thunar",
    audioSettings = "pavucontrol",

    -- Touchpad / gestures
    touchpadDisableTyping    = true,
    touchpadScrollFactor     = 0.3,
    gestureFingers           = 3,
    workspaceSwipeFingers    = 3,
    gestureFingersMore       = 4,
    gestureFingersFullscreen = 3,

    -- Blur — universal, on by default (decoration.lua will wire these in)
    blurEnabled      = true,
    blurSpecialWs    = false,   -- was false in your old config; you asked for "everything"
    blurPopups       = true,
    blurInputMethods = true,
    blurSize         = 8,
    blurPasses       = 3,
    blurXray         = false,

    -- Shadow
    shadowEnabled     = true,
    shadowRange       = 15,
    shadowRenderPower = 4,
    shadowColour      = "rgba(" .. scheme.inversePrimary .. "10)",

    -- Gaps
    workspaceGaps       = 20,
    windowGapsIn        = 5,
    windowGapsOut       = 10,
    singleWindowGapsOut = 10,

    -- Window styling — transparency for everything (opacity < 1 globally);
    -- opaque-app exceptions get overridden per-window in rules.lua, not here.
    windowOpacity              = 0.85,
    windowRounding             = 15,
    windowBorderSize           = 1,
    activeWindowBorderColour   = "rgba(" .. scheme.primary .. "e6)",
    inactiveWindowBorderColour = "rgba(" .. scheme.onSurfaceVariant .. "11)",

    -- Misc
    volumeStep      = 10,
    volumeMax       = 100,
    cursorTheme     = "Adwaita",   -- adwaita-cursors is installed; no "sweet-cursors" package present
    cursorSize      = 24,
    sleepGestureCmd = "systemctl suspend-then-hibernate",

    ------------------
    ---- KEYBINDS ----
    ------------------

    -- Workspaces
    kbMoveWinToWs          = "SUPER + SHIFT",
    kbMoveWinToWsGroup     = "CTRL + SUPER + ALT",
    kbGoToWs               = "SUPER",
    kbGoToWsGroup          = "CTRL + SUPER",
    kbNextWs               = "CTRL + SUPER + Right",
    kbPrevWs               = "CTRL + SUPER + Left",
    kbToggleWsLayout       = "f12",
    kbToggleWsScrollLayout = "SUPER + Space",

    -- Window group
    kbWindowGroupCycleNext = "ALT + TAB",
    kbWindowGroupCyclePrev = "SHIFT + ALT + TAB",
    kbUngroup              = "SUPER + U",
    kbToggleGroup          = "SUPER + Comma",

    -- Window action
    kbWindowPip                = "f7",
    kbWindowPseudo             = "f8",
    kbPinWindow                = "f9",
    kbWindowFullscreen         = "f10",
    kbWindowBorderedFullscreen = "SUPER + ALT + F",
    kbToggleWindowFloating     = "f11",
    kbCloseWindow              = "SUPER + C",

    -- Special workspace toggles
    kbSpecialWs       = "SUPER + S",
    kbSystemMonitorWs = "CTRL + SHIFT + Escape",
    kbMusicWs         = "SUPER + M",
    kbCommunicationWs = "SUPER + D",
    kbTodoWs          = "SUPER + R",

    -- Apps
    kbTerminal     = "SUPER + Return",
    kbBrowser      = "SUPER + B",
    kbEditor       = "SUPER + E",
    kbFileExplorer = "SUPER + T",

    -- Misc
    kbSession     = "ALT + f4",
    kbShowSidebar = "SUPER + N",
    kbClearNotifs = "CTRL + ALT + C",
    kbShowPanels  = "SUPER + K",
    kbLock        = "SUPER + L",
    kbRestoreLock = "SUPER + ALT + L",

    -- Caelestia (caelestia-cli + caelestia-shell are both installed)
    enable_caelestia   = true,
    kbKillCaelestia    = "CTRL + ALT + Delete",
    kbRestartCaelestia = "CTRL + SHIFT + R",

    -- Float rules — keyed by lowercase window class, built from packages you
    -- actually have installed (dolphin AND thunar both present; both get an
    -- entry so rules.lua can size either one correctly regardless of which
    -- you launch manually).
    floatRules = {
        ["thunar"]              = { w = 1000, h = 600, x = 100, y = 100 },
        ["org.kde.dolphin"]     = { w = 1000, h = 800, x = 200, y = 200 },
        ["foot"]                = { w = 1000, h = 600 },
        ["org.pulseaudio.pavucontrol"] = { w = 800, h = 600 },
        ["blueman-manager"]     = { w = 700, h = 500 },
        ["nwg-look"]            = { w = 900, h = 700 },
        ["org.kde.partitionmanager"] = { w = 1100, h = 700 },
    },

    defaultRule = { w = 1000, h = 600 },
}
