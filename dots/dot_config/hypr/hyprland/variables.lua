-- ~/.config/hypr/hyprland/variables.lua
-- dream-wa1ker
-- Central configuration for applications, behavior, and every default keybinding.

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
    ------------------
    ---- KEYBINDS ----
    ------------------
    -- Shortcut settings use tables: terminal = { key = "SUPER + Return" }.
    -- Change your keys in custom/variables.lua, under its existing keybinds table.
    -- To disable: mediaStop = { enabled = false }. To remap: terminal = { key = "..." }.
    -- Behavior is defined in hyprland/keybinds.lua; custom/keybinds.lua adds/overrides it.
    -- The setting name matches the binding's id. Workspace prefixes allow key/enabled only.
    keybinds = {
        -- Noctalia / shell
        launcher             = { key = "SUPER + SUPER_L" },
        keybindCheatsheet    = { key = "SUPER + K" },
        clipboard            = { key = "SUPER + V" },
        emojiSearch          = { key = "SUPER + Period" },
        shellPanelSelector   = { key = "SUPER + Slash" },
        windowSwitcher       = { key = "SUPER + Tab" },
        dashboard            = { key = "SUPER + A" },
        notifications        = { key = "SUPER + N" },
        mediaPanel           = { key = "SUPER + M" },
        barToggle            = { key = "SUPER + J" },
        sessionPanel         = { key = "ALT + F4" },
        lockScreen           = { key = "SUPER + L" },
        reloadNoctalia       = { key = "CTRL + ALT + DELETE" },
        suspend              = { key = "SUPER + SHIFT + L" },
        archUpdater          = { key = "SUPER + U" },
        pomodoro             = { key = "SUPER + F" },
        notes                = { key = "SUPER + H" },
        liveAnnotation       = { key = "SUPER + G" },
        ocrRegion            = { key = "SUPER + X" },
        frozenAnnotation    = { key = "SUPER + SHIFT + G" },
        ocrFullscreen        = { key = "SUPER + SHIFT + X" },
        recordFullscreen     = { key = "SUPER + R" },
        recordRegion         = { key = "SUPER + SHIFT + R" },
        stopRecording        = { key = "SUPER + ALT + R" },
        screenshotRegion     = { key = "SUPER + SHIFT + S" },
        screenshotClipboard  = { key = "CTRL + Print" },
        screenshotSave       = { key = "Print" },
        noctaliaProfileSwitcher = { key = "SUPER + ALT + Space" },
        wallpaperSelector    = { key = "SUPER + W" },
        randomWallpaper      = { key = "CTRL + SUPER + ALT + T" },
        noctaliaSettings     = { key = "SUPER + I" },

        -- Workspace focus / movement
        goToWorkspacePrefix       = { key = "SUPER" },
        moveWindowToWorkspacePrefix = { key = "SUPER + SHIFT" },
        goToWorkspaceGroupPrefix  = { key = "CTRL + SUPER" },
        moveWindowToWorkspaceGroupPrefix = { key = "CTRL + SUPER + ALT" },
        previousWorkspace         = { key = "CTRL + SUPER + Left" },
        nextWorkspace             = { key = "CTRL + SUPER + Right" },
        previousWorkspaceMouse    = { key = "SUPER + mouse_down" },
        nextWorkspaceMouse        = { key = "SUPER + mouse_up" },
        previousWorkspaceGroup    = { key = "SUPER + Page_Up" },
        nextWorkspaceGroup        = { key = "SUPER + Page_down" },
        previousWorkspaceGroupMouse = { key = "CTRL + SUPER + mouse_down" },
        nextWorkspaceGroupMouse     = { key = "CTRL + SUPER + mouse_up" },
        moveWindowPreviousWorkspace = { key = "SUPER + ALT + Page_Up" },
        moveWindowNextWorkspace     = { key = "SUPER + ALT + Page_Down" },
        moveWindowPreviousWorkspaceMouse = { key = "SUPER + ALT + mouse_down" },
        moveWindowNextWorkspaceMouse     = { key = "SUPER + ALT + mouse_up" },
        moveWindowNextWorkspaceGroup     = { key = "CTRL + SUPER + SHIFT + right" },
        moveWindowPreviousWorkspaceGroup = { key = "CTRL + SUPER + SHIFT + left" },
        moveWindowToSpecialWorkspace = { key = "CTRL + SUPER + up" },
        moveWindowOutOfSpecialWorkspace = { key = "CTRL + SUPER + down" },

        -- Named special workspaces
        specialWorkspace       = { key = "SUPER + S" },
        sysmonWorkspace        = { key = "SUPER + Y" },
        communicationWorkspace = { key = "SUPER + D" },

        -- Group management
        toggleGroup       = { key = "SUPER + Comma" },
        ungroupWindow     = { key = "SUPER + SHIFT + Comma" },
        lockActiveGroup   = { key = "SUPER + ALT + Comma" },
        nextWindowInGroup = { key = "ALT + Tab" },
        previousWindowInGroup = { key = "SHIFT + ALT + Tab" },
        nextGroupWindow   = { key = "CTRL + Tab" },
        previousGroupWindow = { key = "CTRL + SHIFT + Tab" },

        -- Window focus / movement
        focusLeft  = { key = "SUPER + left" },
        focusRight = { key = "SUPER + right" },
        focusUp    = { key = "SUPER + up" },
        focusDown  = { key = "SUPER + down" },
        moveLeft   = { key = "SUPER + SHIFT + left" },
        moveRight  = { key = "SUPER + SHIFT + right" },
        moveUp     = { key = "SUPER + SHIFT + up" },
        moveDown   = { key = "SUPER + SHIFT + down" },

        -- Window resizing
        shrinkWidth       = { key = "SUPER + Minus" },
        expandWidth       = { key = "SUPER + Equal" },
        shrinkHeight      = { key = "SUPER + SHIFT + Minus" },
        expandHeight      = { key = "SUPER + SHIFT + Equal" },
        shrinkWidthAlt    = { key = "SUPER + ALT + left" },
        expandWidthAlt    = { key = "SUPER + ALT + right" },
        shrinkHeightAlt   = { key = "SUPER + ALT + up" },
        expandHeightAlt   = { key = "SUPER + ALT + down" },
        dragWindow        = { key = "SUPER + mouse:272" },
        resizeWindowMouse = { key = "SUPER + mouse:273" },
        centerWindow      = { key = "SUPER + Backslash" },
        resizeWindowToScreen = { key = "CTRL + Backslash" },

        -- Placement submap: press the prefix, release it, then one preset key.
        geometryMode = { key = "SUPER + Z" },
        geometryLeft = { key = "H" }, geometryRight = { key = "L" },
        geometryTop = { key = "K" }, geometryBottom = { key = "J" },
        geometryTopLeft = { key = "Y" }, geometryTopRight = { key = "U" },
        geometryBottomLeft = { key = "B" }, geometryBottomRight = { key = "N" },
        geometryCenter = { key = "C" }, geometryFill = { key = "F" }, geometryRestore = { key = "R" },

        -- Window modes / layout
        pictureInPicture       = { key = "f6" },
        pinWindow              = { key = "F7" },
        pseudotileWindow       = { key = "F8" },
        maximizedWindow        = { key = "f9" },
        fullscreenWindow       = { key = "F10" },
        toggleFloating         = { key = "F11" },
        cycleWorkspaceLayout   = { key = "F12" },
        closeWindow            = { key = "SUPER + C" },
        toggleScrollLayout     = { key = "SUPER + Space" },
        scrollHorizontal       = { key = "SUPER + ALT + H" },
        scrollVertical         = { key = "SUPER + ALT + V" },

        -- Applications
        terminal        = { key = "SUPER + Return" },
        browser         = { key = "SUPER + B" },
        editor          = { key = "SUPER + E" },
        fileExplorer    = { key = "SUPER + T" },
        audioMixer      = { key = "CTRL + ALT + V" },
        floatingTerminal     = { key = "SHIFT + SUPER + Return" },
        floatingBrowser      = { key = "SHIFT + SUPER + B" },
        floatingEditor       = { key = "SHIFT + SUPER + E" },
        floatingFileExplorer = { key = "SHIFT + SUPER + T" },
        pseudotiledTerminal  = { key = "CTRL + SUPER + Return" },
        colorPicker          = { key = "SUPER + P" },

        -- Audio / brightness / keyboard backlight
        microphoneMute  = { key = "XF86AudioMicMute" },
        audioMute       = { key = "XF86AudioMute" },
        audioMuteAlt    = { key = "SUPER + SHIFT + M" },
        volumeUp        = { key = "XF86AudioRaiseVolume" },
        volumeDown      = { key = "XF86AudioLowerVolume" },
        brightnessUp    = { key = "XF86MonBrightnessUp" },
        brightnessDown  = { key = "XF86MonBrightnessDown" },
        keyboardBacklightUp   = { key = "SUPER + XF86MonBrightnessUp" },
        keyboardBacklightDown = { key = "SUPER + XF86MonBrightnessDown" },

        -- Media playback
        mediaPlay       = { key = "XF86AudioPlay" },
        mediaPause      = { key = "XF86AudioPause" },
        mediaPlayAlt    = { key = "SUPER + SHIFT + Space" },
        mediaNext       = { key = "XF86AudioNext" },
        mediaNextAlt    = { key = "CTRL + SUPER + Equal" },
        mediaNextAlt2   = { key = "SUPER + SHIFT + N" },
        mediaPrevious   = { key = "XF86AudioPrev" },
        mediaPreviousAlt = { key = "CTRL + SUPER + Minus" },
        mediaPreviousAlt2 = { key = "SUPER + SHIFT + P" },
        mediaStop       = { key = "XF86AudioStop" },

        -- Custom actions (keys remain centrally configurable)
        powerSaver = { key = "SUPER + ALT + B" },
        customEditKeybinds = { key = "CTRL + SUPER + ALT + Slash" },
        customCloseWindow  = { key = "SUPER + Q" },
    },
}
