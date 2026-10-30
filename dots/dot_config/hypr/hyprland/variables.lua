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
    -- Every literal default shortcut lives here. Actions remain in keybinds.lua.
    keybinds = {
        -- Noctalia / shell
        launcher             = "SUPER + SUPER_L",
        keybindCheatsheet    = "SUPER + K",
        clipboard            = "SUPER + V",
        emojiSearch          = "SUPER + Period",
        shellPanelSelector   = "SUPER + Slash",
        windowSwitcher       = "SUPER + Tab",
        dashboard            = "SUPER + A",
        notifications        = "SUPER + N",
        mediaPanel           = "SUPER + M",
        barToggle            = "SUPER + J",
        sessionPanel         = "ALT + F4",
        lockScreen           = "SUPER + L",
        reloadNoctalia       = "CTRL + ALT + DELETE",
        suspend              = "SUPER + SHIFT + L",
        archUpdater          = "SUPER + U",
        pomodoro             = "SUPER + F",
        notes                = "SUPER + H",
        liveAnnotation       = "SUPER + G",
        ocrRegion            = "SUPER + X",
        frozenAnnotation    = "SUPER + SHIFT + G",
        ocrFullscreen        = "SUPER + SHIFT + X",
        recordFullscreen     = "SUPER + R",
        recordRegion         = "SUPER + SHIFT + R",
        stopRecording        = "SUPER + ALT + R",
        screenshotRegion     = "SUPER + SHIFT + S",
        screenshotClipboard  = "CTRL + Print",
        screenshotSave       = "Print",
        noctaliaProfileSwitcher = "SUPER + ALT + Space",
        wallpaperSelector    = "SUPER + W",
        randomWallpaper      = "CTRL + SUPER + ALT + T",
        noctaliaSettings     = "SUPER + I",

        -- Workspace focus / movement
        goToWorkspacePrefix       = "SUPER",
        moveWindowToWorkspacePrefix = "SUPER + SHIFT",
        goToWorkspaceGroupPrefix  = "CTRL + SUPER",
        moveWindowToWorkspaceGroupPrefix = "CTRL + SUPER + ALT",
        previousWorkspace         = "CTRL + SUPER + Left",
        nextWorkspace             = "CTRL + SUPER + Right",
        previousWorkspaceMouse    = "SUPER + mouse_down",
        nextWorkspaceMouse        = "SUPER + mouse_up",
        previousWorkspaceGroup    = "SUPER + Page_Up",
        nextWorkspaceGroup        = "SUPER + Page_down",
        previousWorkspaceGroupMouse = "CTRL + SUPER + mouse_down",
        nextWorkspaceGroupMouse     = "CTRL + SUPER + mouse_up",
        moveWindowPreviousWorkspace = "SUPER + ALT + Page_Up",
        moveWindowNextWorkspace     = "SUPER + ALT + Page_Down",
        moveWindowPreviousWorkspaceMouse = "SUPER + ALT + mouse_down",
        moveWindowNextWorkspaceMouse     = "SUPER + ALT + mouse_up",
        moveWindowNextWorkspaceGroup     = "CTRL + SUPER + SHIFT + right",
        moveWindowPreviousWorkspaceGroup = "CTRL + SUPER + SHIFT + left",
        moveWindowToSpecialWorkspace = "CTRL + SUPER + up",
        moveWindowOutOfSpecialWorkspace = "CTRL + SUPER + down",

        -- Named special workspaces
        specialWorkspace       = "SUPER + S",
        sysmonWorkspace        = "SUPER + Y",
        communicationWorkspace = "SUPER + D",

        -- Group management
        toggleGroup       = "SUPER + Comma",
        ungroupWindow     = "SUPER + SHIFT + Comma",
        lockActiveGroup   = "SUPER + ALT + Comma",
        nextWindowInGroup = "ALT + Tab",
        previousWindowInGroup = "SHIFT + ALT + Tab",
        nextGroupWindow   = "CTRL + Tab",
        previousGroupWindow = "CTRL + SHIFT + Tab",

        -- Window focus / movement
        focusLeft  = "SUPER + left",
        focusRight = "SUPER + right",
        focusUp    = "SUPER + up",
        focusDown  = "SUPER + down",
        moveLeft   = "SUPER + SHIFT + left",
        moveRight  = "SUPER + SHIFT + right",
        moveUp     = "SUPER + SHIFT + up",
        moveDown   = "SUPER + SHIFT + down",

        -- Window resizing
        shrinkWidth       = "SUPER + Minus",
        expandWidth       = "SUPER + Equal",
        shrinkHeight      = "SUPER + SHIFT + Minus",
        expandHeight      = "SUPER + SHIFT + Equal",
        shrinkWidthAlt    = "SUPER + ALT + left",
        expandWidthAlt    = "SUPER + ALT + right",
        shrinkHeightAlt   = "SUPER + ALT + up",
        expandHeightAlt   = "SUPER + ALT + down",
        dragWindow        = "SUPER + mouse:272",
        resizeWindowMouse = "SUPER + mouse:273",
        centerWindow      = "SUPER + Backslash",
        resizeWindowToScreen = "CTRL + Backslash",

        -- Placement submap: press the prefix, release it, then one preset key.
        geometryMode = "SUPER + Z",
        geometryLeft = "H", geometryRight = "L",
        geometryTop = "K", geometryBottom = "J",
        geometryTopLeft = "Y", geometryTopRight = "U",
        geometryBottomLeft = "B", geometryBottomRight = "N",
        geometryCenter = "C", geometryFill = "F", geometryRestore = "R",

        -- Window modes / layout
        pictureInPicture       = "f6",
        pinWindow              = "F7",
        pseudotileWindow       = "F8",
        maximizedWindow        = "f9",
        fullscreenWindow       = "F10",
        toggleFloating         = "F11",
        cycleWorkspaceLayout   = "F12",
        closeWindow            = "SUPER + C",
        toggleScrollLayout     = "SUPER + Space",
        scrollHorizontal       = "SUPER + ALT + H",
        scrollVertical         = "SUPER + ALT + V",

        -- Applications
        terminal        = "SUPER + Return",
        browser         = "SUPER + B",
        editor          = "SUPER + E",
        fileExplorer    = "SUPER + T",
        audioMixer      = "CTRL + ALT + V",
        floatingTerminal     = "SHIFT + SUPER + Return",
        floatingBrowser      = "SHIFT + SUPER + B",
        floatingEditor       = "SHIFT + SUPER + E",
        floatingFileExplorer = "SHIFT + SUPER + T",
        pseudotiledTerminal  = "CTRL + SUPER + Return",
        colorPicker          = "SUPER + P",

        -- Audio / brightness / keyboard backlight
        microphoneMute  = "XF86AudioMicMute",
        audioMute       = "XF86AudioMute",
        audioMuteAlt    = "SUPER + SHIFT + M",
        volumeUp        = "XF86AudioRaiseVolume",
        volumeDown      = "XF86AudioLowerVolume",
        brightnessUp    = "XF86MonBrightnessUp",
        brightnessDown  = "XF86MonBrightnessDown",
        keyboardBacklightUp   = "SUPER + XF86MonBrightnessUp",
        keyboardBacklightDown = "SUPER + XF86MonBrightnessDown",

        -- Media playback
        mediaPlay       = "XF86AudioPlay",
        mediaPause      = "XF86AudioPause",
        mediaPlayAlt    = "SUPER + SHIFT + Space",
        mediaNext       = "XF86AudioNext",
        mediaNextAlt    = "CTRL + SUPER + Equal",
        mediaNextAlt2   = "SUPER + SHIFT + N",
        mediaPrevious   = "XF86AudioPrev",
        mediaPreviousAlt = "CTRL + SUPER + Minus",
        mediaPreviousAlt2 = "SUPER + SHIFT + P",
        mediaStop       = "XF86AudioStop",

        -- Custom overrides (keys remain centrally configurable)
        customEditKeybinds = "CTRL + SUPER + ALT + Slash",
        customCloseWindow  = "SUPER + Q",
    },
}
