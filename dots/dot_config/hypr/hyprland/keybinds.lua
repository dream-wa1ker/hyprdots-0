-- Complete core keybindings: each table contains its own ID, key, and behavior.
-- Personal additions, remaps, disabling, flags, and behavior overrides go in ONE file:
-- ~/.config/hypr/custom/keybinds.lua. Omitted fields inherit these defaults.
-- prefix = true records configure numbered workspace families; they are not bound themselves.
-- Registration/validation/fallbacks live in lib/keybinds.lua.
local registry = require("hyprland.lib.keybinds")
local vars = require("hyprland.variables")
local apps = require("hyprland.lib.apps")
local fn = require("hyprland.functions")
local noctalia = fn.noctalia
local recorder = "noctalia msg plugin h-jangra/region-recorder:service all "
local nextTrack = 'playerctl next || playerctl position `bc <<< "100 * $(playerctl metadata mpris:length) / 1000000 / 100"`'

local bindings = {
    -- Shell
    {
        id = "launcher", key = "SUPER + SUPER_L", description = "Toggle Launcher / Search",
        build_action = function() return noctalia("panel-toggle launcher") end,
        options = {
            release = true,
        },
    },
    {
        id = "keybindCheatsheet", key = "SUPER + K", description = "View Keybindings Cheatsheet",
        build_action = function() return hl.dsp.exec_cmd('bash "$HOME/.dotfiles/scripts/keybinds.sh"') end,
    },
    {
        id = "clipboard", key = "SUPER + V", description = "Toggle Clipboard History",
        build_action = function() return noctalia("panel-toggle clipboard") end,
    },
    {
        id = "emojiSearch", key = "SUPER + Period", description = "Toggle Emoji Searcher",
        build_action = function() return noctalia('panel-toggle launcher "/emo "') end,
    },
    {
        id = "shellPanelSelector", key = "SUPER + Slash", description = "Toggle Shell Panel Selector",
        build_action = function() return noctalia('panel-toggle launcher "/"') end,
    },
    {
        id = "windowSwitcher", key = "SUPER + Tab", description = "Toggle Window Switcher",
        build_action = function() return noctalia("window-switcher hold") end,
    },
    {
        id = "dashboard", key = "SUPER + A", description = "Toggle Main Dashboard",
        build_action = function() return noctalia("panel-toggle control-center") end,
    },
    {
        id = "notifications", key = "SUPER + N", description = "Toggle Notifications Panel",
        build_action = function() return noctalia("panel-toggle control-center notifications") end,
    },
    {
        id = "mediaPanel", key = "SUPER + M", description = "Toggle Media Panel",
        build_action = function() return noctalia("panel-toggle control-center media") end,
    },
    {
        id = "barToggle", key = "SUPER + J", description = "Toggle the Visibility of Default Bar",
        build_action = function() return noctalia("bar-toggle default") end,
    },
    {
        id = "sessionPanel", key = "ALT + F4", description = "Toggle Session Panel",
        build_action = function() return noctalia("panel-toggle session") end,
    },
    {
        id = "lockScreen", key = "SUPER + L", description = "Activate Lock Screen",
        build_action = function() return noctalia("session lock") end,
    },
    {
        id = "reloadNoctalia", key = "CTRL + ALT + DELETE", description = "Reload Noctalia Configuration",
        build_action = function() return noctalia("config-reload") end,
        options = {
            release = true,
        },
    },
    {
        id = "suspend", key = "SUPER + SHIFT + L", description = "Session: Lock and Suspend",
        build_action = function() return noctalia("session lock-and-suspend") end,
        options = {
            locked = true,
        },
    },
    {
        id = "archUpdater", key = "SUPER + U", description = "View Pending Arch System Updates",
        build_action = function() return noctalia("panel-toggle yuuto/arch-updater:panel") end,
    },
    {
        id = "pomodoro", key = "SUPER + F", description = "Toggle Focus Pomodoro",
        build_action = function() return noctalia("panel-toggle thepunkoff/pomodoro:panel") end,
    },
    {
        id = "notes", key = "SUPER + H", description = "Open Notes Side Bar",
        build_action = function() return noctalia("panel-toggle noctalia/notes:panel") end,
    },
    {
        id = "liveAnnotation", key = "SUPER + G", description = "Activate Live Screen Annotation",
        build_action = function() return noctalia("annotate") end,
    },
    {
        id = "ocrRegion", key = "SUPER + X", description = "OCR Selector for a Region",
        build_action = function() return noctalia("plugin fel/ocr:ocr all ocr-region") end,
    },
    {
        id = "frozenAnnotation", key = "SUPER + SHIFT + G", description = "Activate Frozen Screen Annotation",
        build_action = function() return noctalia("screenshot-annotate") end,
    },
    {
        id = "ocrFullscreen", key = "SUPER + SHIFT + X", description = "OCR Selector for Fullscreen",
        build_action = function() return noctalia("plugin fel/ocr:ocr all ocr-screen") end,
    },
    {
        id = "recordFullscreen", key = "SUPER + R", description = "Recording: Start Fullscreen (Audio)",
        build_action = function() return hl.dsp.exec_cmd(recorder .. "record-fullscreen") end,
    },
    {
        id = "recordRegion", key = "SUPER + SHIFT + R", description = "Recording: Select Region (Audio)",
        build_action = function() return hl.dsp.exec_cmd(recorder .. "select-region") end,
    },
    {
        id = "stopRecording", key = "SUPER + ALT + R", description = "Recording: Stop",
        build_action = function() return hl.dsp.exec_cmd(recorder .. "stop") end,
    },
    {
        id = "screenshotRegion", key = "SUPER + SHIFT + S", description = "Screenshot: Region",
        build_action = function() return noctalia("screenshot-region") end,
    },
    {
        id = "screenshotClipboard", key = "CTRL + Print", description = "Copy Monitor Screenshot to Clipboard",
        build_action = function() return hl.dsp.exec_cmd('grim -o "$(hyprctl activeworkspace -j | jq -r \'.monitor\')" - | wl-copy && notify-send -u low "Screenshot" "Monitor screenshot copied to clipboard"') end,
        options = {
            locked = true,
        },
    },
    {
        id = "screenshotSave", key = "Print", description = "Save Monitor Screenshot",
        build_action = function() return hl.dsp.exec_cmd('mkdir -p "$(xdg-user-dir PICTURES)/Screenshots" && grim -o "$(hyprctl activeworkspace -j | jq -r \'.monitor\')" "$(xdg-user-dir PICTURES)/Screenshots/Screenshot_$(date \'+%Y-%m-%d_%H.%M.%S\').png" && notify-send -u low "Screenshot" "Monitor screenshot saved to Pictures/Screenshots"') end,
    },
    {
        id = "noctaliaProfileSwitcher", key = "SUPER + ALT + Space", description = "Switch Desktop Profile",
        build_action = function() return hl.dsp.exec_cmd('bash ~/.dotfiles/scripts/profile-switch') end,
    },
    {
        id = "wallpaperSelector", key = "SUPER + W", description = "Toggle Wallpaper Selector",
        build_action = function() return noctalia("panel-toggle wallpaper") end,
    },
    {
        id = "randomWallpaper", key = "CTRL + SUPER + ALT + T", description = "Set Random Wallpaper",
        build_action = function() return noctalia("wallpaper-random") end,
    },
    {
        id = "noctaliaSettings", key = "SUPER + I", description = "Launch Noctalia Settings",
        build_action = function() return noctalia("settings-toggle") end,
    },

    -- Workspaces
    {
        id = "previousWorkspaceMouse", key = "SUPER + mouse_down", description = "Focus Previous Workspace",
        build_action = function() return hl.dsp.focus({ workspace = "-1" }) end,
    },
    {
        id = "nextWorkspaceMouse", key = "SUPER + mouse_up", description = "Focus Next Workspace",
        build_action = function() return hl.dsp.focus({ workspace = "+1" }) end,
    },
    {
        id = "previousWorkspace", key = "CTRL + SUPER + Left", description = "Focus Previous Workspace",
        build_action = function() return hl.dsp.focus({ workspace = "-1" }) end,
        options = {
            repeating = true,
        },
    },
    {
        id = "nextWorkspace", key = "CTRL + SUPER + Right", description = "Focus Next Workspace",
        build_action = function() return hl.dsp.focus({ workspace = "+1" }) end,
        options = {
            repeating = true,
        },
    },
    {
        id = "moveWindowPreviousWorkspace", key = "SUPER + ALT + Page_Up", description = "Move Window to Previous Workspace",
        build_action = function() return hl.dsp.window.move({ workspace = "-1" }) end,
        options = {
            repeating = true,
        },
    },
    {
        id = "moveWindowNextWorkspace", key = "SUPER + ALT + Page_Down", description = "Move Window to Next Workspace",
        build_action = function() return hl.dsp.window.move({ workspace = "+1" }) end,
        options = {
            repeating = true,
        },
    },
    {
        id = "moveWindowPreviousWorkspaceMouse", key = "SUPER + ALT + mouse_down", description = "Move Window to Previous Workspace",
        build_action = function() return hl.dsp.window.move({ workspace = "-1" }) end,
    },
    {
        id = "moveWindowNextWorkspaceMouse", key = "SUPER + ALT + mouse_up", description = "Move Window to Next Workspace",
        build_action = function() return hl.dsp.window.move({ workspace = "+1" }) end,
    },
    {
        id = "previousWorkspaceGroup", key = "SUPER + Page_Up", description = "Focus Previous Workspace Group",
        build_action = function() return hl.dsp.focus({ workspace = "-10" }) end,
        options = {
            repeating = true,
        },
    },
    {
        id = "nextWorkspaceGroup", key = "SUPER + Page_down", description = "Focus Next Workspace Group",
        build_action = function() return hl.dsp.focus({ workspace = "+10" }) end,
        options = {
            repeating = true,
        },
    },
    {
        id = "previousWorkspaceGroupMouse", key = "CTRL + SUPER + mouse_down", description = "Focus Previous Workspace Group",
        build_action = function() return hl.dsp.focus({ workspace = "-10" }) end,
    },
    {
        id = "nextWorkspaceGroupMouse", key = "CTRL + SUPER + mouse_up", description = "Focus Next Workspace Group",
        build_action = function() return hl.dsp.focus({ workspace = "+10" }) end,
    },
    {
        id = "moveWindowNextWorkspaceGroup", key = "CTRL + SUPER + SHIFT + right", description = "Move Window to Next Workspace Group",
        build_action = function() return hl.dsp.window.move({ workspace = "+10" }) end,
        options = {
            repeating = true,
        },
    },
    {
        id = "moveWindowPreviousWorkspaceGroup", key = "CTRL + SUPER + SHIFT + left", description = "Move Window to Previous Workspace Group",
        build_action = function() return hl.dsp.window.move({ workspace = "-10" }) end,
        options = {
            repeating = true,
        },
    },
    {
        id = "specialWorkspace", key = "SUPER + S", description = "Toggle Special Workspace",
        build_action = function() return hl.dsp.workspace.toggle_special("special") end,
    },
    {
        id = "sysmonWorkspace", key = "SUPER + Y", description = "Toggle Sysmon Workspace",
        build_action = function() return hl.dsp.workspace.toggle_special("sysmon") end,
    },
    {
        id = "communicationWorkspace", key = "SUPER + D", description = "Toggle Communication Workspace",
        build_action = function() return hl.dsp.workspace.toggle_special("communication") end,
    },
    {
        id = "moveWindowToSpecialWorkspace", key = "CTRL + SUPER + up", description = "Move Window to Special Workspace",
        build_action = function() return hl.dsp.window.move({ workspace = "special:special" }) end,
    },
    {
        id = "moveWindowOutOfSpecialWorkspace", key = "CTRL + SUPER + down", description = "Move Window Out of Special Workspace",
        build_action = function() return hl.dsp.window.move({ workspace = "e+0" }) end,
    },

    -- Windows
    {
        id = "toggleGroup", key = "SUPER + Comma", description = "Toggle Window Grouping",
        build_action = function() return hl.dsp.group.toggle() end,
    },
    {
        id = "ungroupWindow", key = "SUPER + SHIFT + Comma", description = "Move Window Out of Group",
        build_action = function() return hl.dsp.window.move({ out_of_group = true }) end,
    },
    {
        id = "lockActiveGroup", key = "SUPER + ALT + Comma", description = "Lock Active Group",
        build_action = function() return hl.dsp.group.lock() end,
    },
    {
        id = "nextWindowInGroup", key = "ALT + Tab", description = "Focus Next Window in Group",
        build_action = function() return hl.dsp.window.cycle_next() end,
        options = {
            repeating = true,
        },
    },
    {
        id = "previousWindowInGroup", key = "SHIFT + ALT + Tab", description = "Focus Previous Window in Group",
        build_action = function() return hl.dsp.window.cycle_next({ next = false }) end,
        options = {
            repeating = true,
        },
    },
    {
        id = "nextGroupWindow", key = "CTRL + Tab", description = "Switch to Next Group Window",
        build_action = function() return hl.dsp.group.next() end,
        options = {
            repeating = true,
        },
    },
    {
        id = "previousGroupWindow", key = "CTRL + SHIFT + Tab", description = "Switch to Previous Group Window",
        build_action = function() return hl.dsp.group.prev() end,
        options = {
            repeating = true,
        },
    },
    {
        id = "focusLeft", key = "SUPER + left", description = "Focus Left Window",
        build_action = function() return hl.dsp.focus({ direction = "left" }) end,
    },
    {
        id = "focusRight", key = "SUPER + right", description = "Focus Right Window",
        build_action = function() return hl.dsp.focus({ direction = "right" }) end,
    },
    {
        id = "focusUp", key = "SUPER + up", description = "Focus Up Window",
        build_action = function() return hl.dsp.focus({ direction = "up" }) end,
    },
    {
        id = "focusDown", key = "SUPER + down", description = "Focus Down Window",
        build_action = function() return hl.dsp.focus({ direction = "down" }) end,
    },
    {
        id = "moveLeft", key = "SUPER + SHIFT + left", description = "Move Window Left",
        build_action = function() return hl.dsp.window.move({ direction = "left" }) end,
    },
    {
        id = "moveRight", key = "SUPER + SHIFT + right", description = "Move Window Right",
        build_action = function() return hl.dsp.window.move({ direction = "right" }) end,
    },
    {
        id = "moveUp", key = "SUPER + SHIFT + up", description = "Move Window Up",
        build_action = function() return hl.dsp.window.move({ direction = "up" }) end,
    },
    {
        id = "moveDown", key = "SUPER + SHIFT + down", description = "Move Window Down",
        build_action = function() return hl.dsp.window.move({ direction = "down" }) end,
    },
    {
        id = "shrinkWidth", key = "SUPER + Minus", description = "Shrink Window Width",
        build_action = function() return fn.resize_active(-10, 0) end,
        options = {
            repeating = true,
        },
    },
    {
        id = "expandWidth", key = "SUPER + Equal", description = "Expand Window Width",
        build_action = function() return fn.resize_active(10, 0) end,
        options = {
            repeating = true,
        },
    },
    {
        id = "shrinkHeight", key = "SUPER + SHIFT + Minus", description = "Shrink Window Height",
        build_action = function() return fn.resize_active(0, -10) end,
        options = {
            repeating = true,
        },
    },
    {
        id = "expandHeight", key = "SUPER + SHIFT + Equal", description = "Expand Window Height",
        build_action = function() return fn.resize_active(0, 10) end,
        options = {
            repeating = true,
        },
    },
    {
        id = "shrinkWidthAlt", key = "SUPER + ALT + left", description = "Shrink Window Width",
        build_action = function() return fn.resize_active(-10, 0) end,
        options = {
            repeating = true,
        },
    },
    {
        id = "expandWidthAlt", key = "SUPER + ALT + right", description = "Expand Window Width",
        build_action = function() return fn.resize_active(10, 0) end,
        options = {
            repeating = true,
        },
    },
    {
        id = "shrinkHeightAlt", key = "SUPER + ALT + up", description = "Shrink Window Height",
        build_action = function() return fn.resize_active(0, -10) end,
        options = {
            repeating = true,
        },
    },
    {
        id = "expandHeightAlt", key = "SUPER + ALT + down", description = "Expand Window Height",
        build_action = function() return fn.resize_active(0, 10) end,
        options = {
            repeating = true,
        },
    },
    {
        id = "dragWindow", key = "SUPER + mouse:272", description = "Move Window Using Mouse",
        build_action = function() return hl.dsp.window.drag() end,
        options = {
            mouse = true,
        },
    },
    {
        id = "resizeWindowMouse", key = "SUPER + mouse:273", description = "Resize Window Using Mouse",
        build_action = function() return hl.dsp.window.resize() end,
        options = {
            mouse = true,
        },
    },
    {
        id = "centerWindow", key = "SUPER + Backslash", description = "Move Window to Screen Center",
        build_action = function() return hl.dsp.window.center() end,
    },
    {
        id = "resizeWindowToScreen", key = "CTRL + Backslash", description = "Resize Window to 55x70 Percent of Screen",
        build_action = function() return fn.resize_screen(55, 70) end,
    },
    {
        id = "pictureInPicture", key = "f6", description = "Toggle Picture-in-Picture Mode",
        build_action = function() return fn.toggle_pip end,
    },
    {
        id = "pinWindow", key = "F7", description = "Pin/Unpin Window",
        build_action = function() return hl.dsp.window.pin() end,
    },
    {
        id = "pseudotileWindow", key = "F8", description = "Toggle Pseudotiled Mode",
        build_action = function() return hl.dsp.window.pseudo() end,
    },
    {
        id = "fullscreenWindow", key = "F10", description = "Toggle Fullscreen Mode",
        build_action = function() return hl.dsp.window.fullscreen({ mode = "fullscreen" }) end,
    },
    {
        id = "maximizedWindow", key = "f9", description = "Toggle Maximized Mode",
        build_action = function() return hl.dsp.window.fullscreen({ mode = "maximized" }) end,
    },
    {
        id = "toggleFloating", key = "F11", description = "Toggle Floating Mode",
        build_action = function() return fn.toggle_floating end,
    },
    {
        id = "closeWindow", key = "SUPER + C", description = "Close Active Window",
        build_action = function() return hl.dsp.window.close() end,
    },
    {
        id = "cycleWorkspaceLayout", key = "F12", description = "Cycle Workspace Layout (All Types)",
        build_action = function() return fn.cycle_all_layouts end,
    },
    {
        id = "toggleScrollLayout", key = "SUPER + Space", description = "Toggle between Dwindle and Scrolling Layout",
        build_action = function() return fn.toggle_scroll_layout end,
    },

    -- Applications
    {
        id = "terminal", key = "SUPER + Return", description = "Launch Default Terminal",
        build_action = function() return apps.launch("terminal") end,
    },
    {
        id = "browser", key = "SUPER + B", description = "Launch Default Web Browser",
        build_action = function() return apps.launch("browser") end,
    },
    {
        id = "editor", key = "SUPER + E", description = "Launch Default Text Editor",
        build_action = function() return apps.launch("editor") end,
    },
    {
        id = "fileExplorer", key = "SUPER + T", description = "Launch Default File Manager",
        build_action = function() return apps.launch("fileManager") end,
    },
    {
        id = "audioMixer", key = "CTRL + ALT + V", description = "Launch Volume Mixer",
        build_action = function() return apps.launch("audioMixer") end,
    },
    {
        id = "floatingTerminal", key = "SHIFT + SUPER + Return", description = "Launch Terminal in (Floating)",
        build_action = function() return apps.launch("terminal", { floating = true }) end,
    },
    {
        id = "floatingBrowser", key = "SHIFT + SUPER + B", description = "Launch Web Browser in (Floating)",
        build_action = function() return apps.launch("browser", { floating = true }) end,
    },
    {
        id = "floatingEditor", key = "SHIFT + SUPER + E", description = "Launch Text Editor in (Floating)",
        build_action = function() return apps.launch("editor", { floating = true }) end,
    },
    {
        id = "floatingFileExplorer", key = "SHIFT + SUPER + T", description = "Launch File Manager in (Floating)",
        build_action = function() return apps.launch("fileManager", { floating = true }) end,
    },
    {
        id = "pseudotiledTerminal", key = "CTRL + SUPER + Return", description = "Launch Terminal in (Pseudotiled)",
        build_action = function() return apps.launch("terminal", { pseudo = true }) end,
    },
    {
        id = "colorPicker", key = "SUPER + P", description = "Launch Color Picker",
        build_action = function() return apps.launch("colorPicker") end,
    },

    -- Media
    {
        id = "microphoneMute", key = "XF86AudioMicMute", description = "Toggle Microphone Mute",
        build_action = function() return hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle") end,
        options = {
            locked = true,
        },
    },
    {
        id = "audioMute", key = "XF86AudioMute", description = "Toggle Audio Mute",
        build_action = function() return hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle") end,
        options = {
            locked = true,
        },
    },
    {
        id = "audioMuteAlt", key = "SUPER + SHIFT + M", description = "Toggle Audio Mute",
        build_action = function() return hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle") end,
        options = {
            locked = true,
        },
    },
    {
        id = "volumeUp", key = "XF86AudioRaiseVolume", description = "Increase Audio Volume",
        build_action = function() return hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; wpctl set-volume -l " .. (vars.volumeMax / 100) .. " @DEFAULT_AUDIO_SINK@ " .. vars.volumeStep .. "%+") end,
        options = {
            locked = true,
            repeating = true,
        },
    },
    {
        id = "volumeDown", key = "XF86AudioLowerVolume", description = "Decrease Audio Volume",
        build_action = function() return hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; wpctl set-volume @DEFAULT_AUDIO_SINK@ " .. vars.volumeStep .. "%-") end,
        options = {
            locked = true,
            repeating = true,
        },
    },
    {
        id = "brightnessUp", key = "XF86MonBrightnessUp", description = "Increase Display Brightness",
        build_action = function() return hl.dsp.exec_cmd("brightnessctl s 5%+") end,
        options = {
            locked = true,
        },
    },
    {
        id = "brightnessDown", key = "XF86MonBrightnessDown", description = "Decrease Display Brightness",
        build_action = function() return hl.dsp.exec_cmd("brightnessctl s 5%-") end,
        options = {
            locked = true,
        },
    },
    {
        id = "keyboardBacklightUp", key = "SUPER + XF86MonBrightnessUp", description = "Increase Keyboard Backlight",
        build_action = function() return hl.dsp.exec_cmd("brightnessctl -d platform::kbd_backlight set +1") end,
    },
    {
        id = "keyboardBacklightDown", key = "SUPER + XF86MonBrightnessDown", description = "Decrease Keyboard Backlight",
        build_action = function() return hl.dsp.exec_cmd("brightnessctl -d platform::kbd_backlight set 1-") end,
    },
    {
        id = "mediaPlay", key = "XF86AudioPlay", description = "Toggle Play/Pause",
        build_action = function() return hl.dsp.exec_cmd("playerctl play-pause") end,
        options = {
            locked = true,
        },
    },
    {
        id = "mediaPause", key = "XF86AudioPause", description = "Toggle Play/Pause",
        build_action = function() return hl.dsp.exec_cmd("playerctl play-pause") end,
        options = {
            locked = true,
        },
    },
    {
        id = "mediaPlayAlt", key = "SUPER + SHIFT + Space", description = "Toggle Play/Pause",
        build_action = function() return hl.dsp.exec_cmd("playerctl play-pause") end,
    },
    {
        id = "mediaNext", key = "XF86AudioNext", description = "Play Next Track",
        build_action = function() return hl.dsp.exec_cmd(nextTrack) end,
        options = {
            locked = true,
        },
    },
    {
        id = "mediaNextAlt", key = "CTRL + SUPER + Equal", description = "Play Next Track",
        build_action = function() return hl.dsp.exec_cmd(nextTrack) end,
        options = {
            locked = true,
        },
    },
    {
        id = "mediaNextAlt2", key = "SUPER + SHIFT + N", description = "Play Next Track",
        build_action = function() return hl.dsp.exec_cmd(nextTrack) end,
    },
    {
        id = "mediaPrevious", key = "XF86AudioPrev", description = "Play Previous Track",
        build_action = function() return hl.dsp.exec_cmd("playerctl previous") end,
        options = {
            locked = true,
        },
    },
    {
        id = "mediaPreviousAlt", key = "CTRL + SUPER + Minus", description = "Play Previous Track",
        build_action = function() return hl.dsp.exec_cmd("playerctl previous") end,
        options = {
            locked = true,
        },
    },
    {
        id = "mediaPreviousAlt2", key = "SUPER + SHIFT + P", description = "Play Previous Track",
        build_action = function() return hl.dsp.exec_cmd("playerctl previous") end,
    },
    {
        id = "mediaStop", key = "XF86AudioStop", description = "Stop Playback",
        build_action = function() return hl.dsp.exec_cmd("playerctl stop") end,
        options = {
            locked = true,
        },
    },

    -- Placement
    {
        id = "geometryMode", key = "SUPER + Z", description = "Enter Window Placement Mode",
        build_action = function() return hl.dsp.submap("geometry") end,
    },
    {
        id = "scrollHorizontal", key = "SUPER + ALT + H", description = "Scrolling Layout: Horizontal",
        action = function() fn.set_scroll_direction("right") end,
    },
    {
        id = "scrollVertical", key = "SUPER + ALT + V", description = "Scrolling Layout: Vertical",
        action = function() fn.set_scroll_direction("down") end,
    },
}

local function numbered_bindings()
    local entries = {}
    local families = {
        {"workspace.focus", "goToWorkspacePrefix", "focus", "", "Focus Workspace ", "SUPER"},
        {"workspace.move", "moveWindowToWorkspacePrefix", "move", "", "Workspaces: Move Window to Workspace ", "SUPER + SHIFT"},
        {"workspace.groupFocus", "goToWorkspaceGroupPrefix", "focus", "group", "Focus Workspace Group ", "CTRL + SUPER"},
        {"workspace.groupMove", "moveWindowToWorkspaceGroupPrefix", "move", "group", "Move Window to Workspace Group ", "CTRL + SUPER + ALT"},
    }
    -- Override a whole family by its existing prefix ID in custom/keybinds.lua.
    for _, family in ipairs(families) do
        entries[#entries + 1] = {id = family[2], key = family[6], prefix = true}
    end
    for i = 1, 10 do
        for _, family in ipairs(families) do
            local id, prefix, verb, range, description = table.unpack(family)
            local index = i
            entries[#entries + 1] = {
                id = id .. "." .. index, parent = prefix,
                key = family[6] .. " + " .. (index % 10), suffix = tostring(index % 10),
                description = description .. index,
                build_action = function() return fn.wsaction(verb, range, index) end,
            }
        end
    end
    return entries
end

local function placement_bindings()
    local entries = {
        {id = "geometry.cancel", key = "Escape", submap = "geometry", internal = true,
            description = "Cancel Window Placement", build_action = function() return hl.dsp.submap("reset") end},
        {id = "geometry.catchall", key = "catchall", submap = "geometry", internal = true,
            description = "Cancel Window Placement", build_action = function() return hl.dsp.submap("reset") end},
    }
    local presets = {
        {"geometryLeft", "left", "H"}, {"geometryRight", "right", "L"},
        {"geometryTop", "top", "K"}, {"geometryBottom", "bottom", "J"},
        {"geometryTopLeft", "top_left", "Y"}, {"geometryTopRight", "top_right", "U"},
        {"geometryBottomLeft", "bottom_left", "B"}, {"geometryBottomRight", "bottom_right", "N"},
        {"geometryCenter", "center", "C"}, {"geometryFill", "fill", "F"}, {"geometryRestore", "restore", "R"},
    }
    for _, pair in ipairs(presets) do
        local id, preset = pair[1], pair[2]
        entries[#entries + 1] = {
            id = id, key = pair[3], submap = "geometry", description = "Window Placement: " .. preset,
            action = function()
                hl.dispatch(hl.dsp.submap("reset"))
                if preset == "restore" then fn.restore_window_placement()
                else fn.place_window(preset) end
            end,
        }
    end
    return entries
end

for _, binding in ipairs(numbered_bindings()) do bindings[#bindings + 1] = binding end
for _, binding in ipairs(placement_bindings()) do bindings[#bindings + 1] = binding end
local result = registry.register(bindings, function() return require("custom.keybinds") end)

hl.on("config.unload", function()
    if hl.get_current_submap() == "geometry" then hl.dispatch(hl.dsp.submap("reset")) end
end)

return result
