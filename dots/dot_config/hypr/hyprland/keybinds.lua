-- ~/.config/hypr/hyprland/keybinds.lua
-- Declarative keybinding registry. All shortcut strings live in variables.lua.
local registry = require("hyprland.lib.keybinds")
local vars = require("hyprland.variables")
local fn = require("hyprland.functions")
local kb = type(vars.keybinds) == "table" and vars.keybinds or {}
local noctalia = fn.noctalia
local recorder = "noctalia msg plugin h-jangra/region-recorder:service all "
local nextTrack = 'playerctl next || playerctl position `bc <<< "100 * $(playerctl metadata mpris:length) / 1000000 / 100"`'
local bindings = {
    -- Noctalia / shell
    {
        key = kb.launcher,
        fallback_key = registry.default_key("launcher"),
        build_action = function()
            return noctalia("panel-toggle launcher")
        end,
        options = {
            description = "Toggle Launcher / Search",
            release = true,
        },
    },
    {
        key = kb.keybindCheatsheet,
        fallback_key = registry.default_key("keybindCheatsheet"),
        build_action = function()
            return noctalia("panel-toggle blackbartblues/keymap:panel")
        end,
        options = {
            description = "View Keybindings Cheatsheet",
        },
    },
    {
        key = kb.clipboard,
        fallback_key = registry.default_key("clipboard"),
        build_action = function()
            return noctalia("panel-toggle clipboard")
        end,
        options = {
            description = "Toggle Clipboard History",
        },
    },
    {
        key = kb.emojiSearch,
        fallback_key = registry.default_key("emojiSearch"),
        build_action = function()
            return noctalia('panel-toggle launcher "/emo "')
        end,
        options = {
            description = "Toggle Emoji Searcher",
        },
    },
    {
        key = kb.shellPanelSelector,
        fallback_key = registry.default_key("shellPanelSelector"),
        build_action = function()
            return noctalia('panel-toggle launcher "/"')
        end,
        options = {
            description = "Toggle Shell Panel Selector",
        },
    },
    {
        key = kb.windowSwitcher,
        fallback_key = registry.default_key("windowSwitcher"),
        build_action = function()
            return noctalia("window-switcher hold")
        end,
        options = {
            description = "Toggle Window Switcher",
        },
    },
    {
        key = kb.dashboard,
        fallback_key = registry.default_key("dashboard"),
        build_action = function()
            return noctalia("panel-toggle control-center")
        end,
        options = {
            description = "Toggle Main Dashboard",
        },
    },
    {
        key = kb.notifications,
        fallback_key = registry.default_key("notifications"),
        build_action = function()
            return noctalia("panel-toggle control-center notifications")
        end,
        options = {
            description = "Toggle Notifications Panel",
        },
    },
    {
        key = kb.mediaPanel,
        fallback_key = registry.default_key("mediaPanel"),
        build_action = function()
            return noctalia("panel-toggle control-center media")
        end,
        options = {
            description = "Toggle Media Panel",
        },
    },
    {
        key = kb.barToggle,
        fallback_key = registry.default_key("barToggle"),
        build_action = function()
            return noctalia("bar-toggle default")
        end,
        options = {
            description = "Toggle the Visibility of Default Bar",
        },
    },
    {
        key = kb.sessionPanel,
        fallback_key = registry.default_key("sessionPanel"),
        build_action = function()
            return noctalia("panel-toggle session")
        end,
        options = {
            description = "Toggle Session Panel",
        },
    },
    {
        key = kb.lockScreen,
        fallback_key = registry.default_key("lockScreen"),
        build_action = function()
            return noctalia("session lock")
        end,
        options = {
            description = "Activate Lock Screen",
        },
    },
    {
        key = kb.reloadNoctalia,
        fallback_key = registry.default_key("reloadNoctalia"),
        build_action = function()
            return noctalia("config-reload")
        end,
        options = {
            release = true,
            description = "Reload Noctalia Configuration",
        },
    },
    {
        key = kb.suspend,
        fallback_key = registry.default_key("suspend"),
        build_action = function()
            return noctalia("session lock-and-suspend")
        end,
        options = {
            locked = true,
            description = "Session: Lock and Suspend",
        },
    },
    {
        key = kb.archUpdater,
        fallback_key = registry.default_key("archUpdater"),
        build_action = function()
            return noctalia("panel-toggle yuuto/arch-updater:panel")
        end,
        options = {
            description = "View Pending Arch System Updates",
        },
    },
    {
        key = kb.pomodoro,
        fallback_key = registry.default_key("pomodoro"),
        build_action = function()
            return noctalia("panel-toggle thepunkoff/pomodoro:panel")
        end,
        options = {
            description = "Toggle Focus Pomodoro",
        },
    },
    {
        key = kb.notes,
        fallback_key = registry.default_key("notes"),
        build_action = function()
            return noctalia("panel-toggle noctalia/notes:panel")
        end,
        options = {
            description = "Open Notes Side Bar",
        },
    },
    {
        key = kb.liveAnnotation,
        fallback_key = registry.default_key("liveAnnotation"),
        build_action = function()
            return noctalia("annotate")
        end,
        options = {
            description = "Activate Live Screen Annotation",
        },
    },
    {
        key = kb.ocrRegion,
        fallback_key = registry.default_key("ocrRegion"),
        build_action = function()
            return noctalia("plugin fel/ocr:ocr all ocr-region")
        end,
        options = {
            description = "OCR Selector for a Region",
        },
    },
    {
        key = kb.frozenAnnotation,
        fallback_key = registry.default_key("frozenAnnotation"),
        build_action = function()
            return noctalia("screenshot-annotate")
        end,
        options = {
            description = "Activate Frozen Screen Annotation",
        },
    },
    {
        key = kb.ocrFullscreen,
        fallback_key = registry.default_key("ocrFullscreen"),
        build_action = function()
            return noctalia("plugin fel/ocr:ocr all ocr-screen")
        end,
        options = {
            description = "OCR Selector for Fullscreen",
        },
    },
    {
        key = kb.recordFullscreen,
        fallback_key = registry.default_key("recordFullscreen"),
        build_action = function()
            return hl.dsp.exec_cmd(recorder .. "record-fullscreen")
        end,
        options = {
            description = "Recording: Start Fullscreen (Audio)",
        },
    },
    {
        key = kb.recordRegion,
        fallback_key = registry.default_key("recordRegion"),
        build_action = function()
            return hl.dsp.exec_cmd(recorder .. "select-region")
        end,
        options = {
            description = "Recording: Select Region (Audio)",
        },
    },
    {
        key = kb.stopRecording,
        fallback_key = registry.default_key("stopRecording"),
        build_action = function()
            return hl.dsp.exec_cmd(recorder .. "stop")
        end,
        options = {
            description = "Recording: Stop",
        },
    },
    {
        key = kb.screenshotRegion,
        fallback_key = registry.default_key("screenshotRegion"),
        build_action = function()
            return noctalia("screenshot-region")
        end,
        options = {
            description = "Screenshot: Region",
        },
    },
    {
        key = kb.screenshotClipboard,
        fallback_key = registry.default_key("screenshotClipboard"),
        build_action = function()
            return hl.dsp.exec_cmd('grim -o "$(hyprctl activeworkspace -j | jq -r \'.monitor\')" - | wl-copy && notify-send -u low "Screenshot" "Monitor screenshot copied to clipboard"')
        end,
        options = {
            locked = true,
            description = "Copy Monitor Screenshot to Clipboard",
        },
    },
    {
        key = kb.screenshotSave,
        fallback_key = registry.default_key("screenshotSave"),
        build_action = function()
            return hl.dsp.exec_cmd('mkdir -p "$(xdg-user-dir PICTURES)/Screenshots" && grim -o "$(hyprctl activeworkspace -j | jq -r \'.monitor\')" "$(xdg-user-dir PICTURES)/Screenshots/Screenshot_$(date \'+%Y-%m-%d_%H.%M.%S\').png" && notify-send -u low "Screenshot" "Monitor screenshot saved to Pictures/Screenshots"')
        end,
        options = {
            description = "Save Monitor Screenshot",
        },
    },
    {
        key = kb.noctaliaProfileSwitcher,
        fallback_key = registry.default_key("noctaliaProfileSwitcher"),
        build_action = function()
            return hl.dsp.exec_cmd('bash ~/.dotfiles/scripts/profile-switch')
        end,
        options = {
            description = "Save Monitor Screenshot",
        },
    },

    {
        key = kb.wallpaperSelector,
        fallback_key = registry.default_key("wallpaperSelector"),
        build_action = function()
            return noctalia("panel-toggle wallpaper")
        end,
        options = {
            description = "Toggle Wallpaper Selector",
        },
    },
    {
        key = kb.randomWallpaper,
        fallback_key = registry.default_key("randomWallpaper"),
        build_action = function()
            return noctalia("wallpaper-random")
        end,
        options = {
            description = "Set Random Wallpaper",
        },
    },
    {
        key = kb.noctaliaSettings,
        fallback_key = registry.default_key("noctaliaSettings"),
        build_action = function()
            return noctalia("settings-toggle")
        end,
        options = {
            description = "Launch Noctalia Settings",
        },
    },
    -- Workspace navigation and movement (non-numbered)
    {
        key = kb.previousWorkspaceMouse,
        fallback_key = registry.default_key("previousWorkspaceMouse"),
        build_action = function()
            return hl.dsp.focus({ workspace = "-1" })
        end,
        options = {
            description = "Focus Previous Workspace",
        },
    },
    {
        key = kb.nextWorkspaceMouse,
        fallback_key = registry.default_key("nextWorkspaceMouse"),
        build_action = function()
            return hl.dsp.focus({ workspace = "+1" })
        end,
        options = {
            description = "Focus Next Workspace",
        },
    },
    {
        key = kb.previousWorkspace,
        fallback_key = registry.default_key("previousWorkspace"),
        build_action = function()
            return hl.dsp.focus({ workspace = "-1" })
        end,
        options = {
            repeating = true,
            description = "Focus Previous Workspace",
        },
    },
    {
        key = kb.nextWorkspace,
        fallback_key = registry.default_key("nextWorkspace"),
        build_action = function()
            return hl.dsp.focus({ workspace = "+1" })
        end,
        options = {
            repeating = true,
            description = "Focus Next Workspace",
        },
    },
    {
        key = kb.moveWindowPreviousWorkspace,
        fallback_key = registry.default_key("moveWindowPreviousWorkspace"),
        build_action = function()
            return hl.dsp.window.move({ workspace = "-1" })
        end,
        options = {
            repeating = true,
            description = "Move Window to Previous Workspace",
        },
    },
    {
        key = kb.moveWindowNextWorkspace,
        fallback_key = registry.default_key("moveWindowNextWorkspace"),
        build_action = function()
            return hl.dsp.window.move({ workspace = "+1" })
        end,
        options = {
            repeating = true,
            description = "Move Window to Next Workspace",
        },
    },
    {
        key = kb.moveWindowPreviousWorkspaceMouse,
        fallback_key = registry.default_key("moveWindowPreviousWorkspaceMouse"),
        build_action = function()
            return hl.dsp.window.move({ workspace = "-1" })
        end,
        options = {
            description = "Move Window to Previous Workspace",
        },
    },
    {
        key = kb.moveWindowNextWorkspaceMouse,
        fallback_key = registry.default_key("moveWindowNextWorkspaceMouse"),
        build_action = function()
            return hl.dsp.window.move({ workspace = "+1" })
        end,
        options = {
            description = "Move Window to Next Workspace",
        },
    },
    {
        key = kb.previousWorkspaceGroup,
        fallback_key = registry.default_key("previousWorkspaceGroup"),
        build_action = function()
            return hl.dsp.focus({ workspace = "-10" })
        end,
        options = {
            repeating = true,
            description = "Focus Previous Workspace Group",
        },
    },
    {
        key = kb.nextWorkspaceGroup,
        fallback_key = registry.default_key("nextWorkspaceGroup"),
        build_action = function()
            return hl.dsp.focus({ workspace = "+10" })
        end,
        options = {
            repeating = true,
            description = "Focus Next Workspace Group",
        },
    },
    {
        key = kb.previousWorkspaceGroupMouse,
        fallback_key = registry.default_key("previousWorkspaceGroupMouse"),
        build_action = function()
            return hl.dsp.focus({ workspace = "-10" })
        end,
        options = {
            description = "Focus Previous Workspace Group",
        },
    },
    {
        key = kb.nextWorkspaceGroupMouse,
        fallback_key = registry.default_key("nextWorkspaceGroupMouse"),
        build_action = function()
            return hl.dsp.focus({ workspace = "+10" })
        end,
        options = {
            description = "Focus Next Workspace Group",
        },
    },
    {
        key = kb.moveWindowNextWorkspaceGroup,
        fallback_key = registry.default_key("moveWindowNextWorkspaceGroup"),
        build_action = function()
            return hl.dsp.window.move({ workspace = "+10" })
        end,
        options = {
            repeating = true,
            description = "Move Window to Next Workspace Group",
        },
    },
    {
        key = kb.moveWindowPreviousWorkspaceGroup,
        fallback_key = registry.default_key("moveWindowPreviousWorkspaceGroup"),
        build_action = function()
            return hl.dsp.window.move({ workspace = "-10" })
        end,
        options = {
            repeating = true,
            description = "Move Window to Previous Workspace Group",
        },
    },
    -- Named special workspaces
    {
        key = kb.specialWorkspace,
        fallback_key = registry.default_key("specialWorkspace"),
        build_action = function()
            return hl.dsp.workspace.toggle_special("special")
        end,
        options = {
            description = "Toggle Special Workspace",
        },
    },
    {
        key = kb.sysmonWorkspace,
        fallback_key = registry.default_key("sysmonWorkspace"),
        build_action = function()
            return hl.dsp.workspace.toggle_special("sysmon")
        end,
        options = {
            description = "Toggle Sysmon Workspace",
        },
    },
    {
        key = kb.communicationWorkspace,
        fallback_key = registry.default_key("communicationWorkspace"),
        build_action = function()
            return hl.dsp.workspace.toggle_special("communication")
        end,
        options = {
            description = "Toggle Communication Workspace",
        },
    },
    {
        key = kb.moveWindowToSpecialWorkspace,
        fallback_key = registry.default_key("moveWindowToSpecialWorkspace"),
        build_action = function()
            return hl.dsp.window.move({ workspace = "special:special" })
        end,
        options = {
            description = "Move Window to Special Workspace",
        },
    },
    {
        key = kb.moveWindowOutOfSpecialWorkspace,
        fallback_key = registry.default_key("moveWindowOutOfSpecialWorkspace"),
        build_action = function()
            return hl.dsp.window.move({ workspace = "e+0" })
        end,
        options = {
            description = "Move Window Out of Special Workspace",
        },
    },
    -- Window grouping
    {
        key = kb.toggleGroup,
        fallback_key = registry.default_key("toggleGroup"),
        build_action = function()
            return hl.dsp.group.toggle()
        end,
        options = {
            description = "Toggle Window Grouping",
        },
    },
    {
        key = kb.ungroupWindow,
        fallback_key = registry.default_key("ungroupWindow"),
        build_action = function()
            return hl.dsp.window.move({ out_of_group = true })
        end,
        options = {
            description = "Move Window Out of Group",
        },
    },
    {
        key = kb.lockActiveGroup,
        fallback_key = registry.default_key("lockActiveGroup"),
        build_action = function()
            return hl.dsp.group.lock()
        end,
        options = {
            description = "Lock Active Group",
        },
    },
    {
        key = kb.nextWindowInGroup,
        fallback_key = registry.default_key("nextWindowInGroup"),
        build_action = function()
            return hl.dsp.window.cycle_next()
        end,
        options = {
            repeating = true,
            description = "Focus Next Window in Group",
        },
    },
    {
        key = kb.previousWindowInGroup,
        fallback_key = registry.default_key("previousWindowInGroup"),
        build_action = function()
            return hl.dsp.window.cycle_next({ next = false })
        end,
        options = {
            repeating = true,
            description = "Focus Previous Window in Group",
        },
    },
    {
        key = kb.nextGroupWindow,
        fallback_key = registry.default_key("nextGroupWindow"),
        build_action = function()
            return hl.dsp.group.next()
        end,
        options = {
            repeating = true,
            description = "Switch to Next Group Window",
        },
    },
    {
        key = kb.previousGroupWindow,
        fallback_key = registry.default_key("previousGroupWindow"),
        build_action = function()
            return hl.dsp.group.prev()
        end,
        options = {
            repeating = true,
            description = "Switch to Previous Group Window",
        },
    },
    -- Window focus and movement
    {
        key = kb.focusLeft,
        fallback_key = registry.default_key("focusLeft"),
        build_action = function()
            return hl.dsp.focus({ direction = "left" })
        end,
        options = {
            description = "Focus Left Window",
        },
    },
    {
        key = kb.focusRight,
        fallback_key = registry.default_key("focusRight"),
        build_action = function()
            return hl.dsp.focus({ direction = "right" })
        end,
        options = {
            description = "Focus Right Window",
        },
    },
    {
        key = kb.focusUp,
        fallback_key = registry.default_key("focusUp"),
        build_action = function()
            return hl.dsp.focus({ direction = "up" })
        end,
        options = {
            description = "Focus Up Window",
        },
    },
    {
        key = kb.focusDown,
        fallback_key = registry.default_key("focusDown"),
        build_action = function()
            return hl.dsp.focus({ direction = "down" })
        end,
        options = {
            description = "Focus Down Window",
        },
    },
    {
        key = kb.moveLeft,
        fallback_key = registry.default_key("moveLeft"),
        build_action = function()
            return hl.dsp.window.move({ direction = "left" })
        end,
        options = {
            description = "Move Window Left",
        },
    },
    {
        key = kb.moveRight,
        fallback_key = registry.default_key("moveRight"),
        build_action = function()
            return hl.dsp.window.move({ direction = "right" })
        end,
        options = {
            description = "Move Window Right",
        },
    },
    {
        key = kb.moveUp,
        fallback_key = registry.default_key("moveUp"),
        build_action = function()
            return hl.dsp.window.move({ direction = "up" })
        end,
        options = {
            description = "Move Window Up",
        },
    },
    {
        key = kb.moveDown,
        fallback_key = registry.default_key("moveDown"),
        build_action = function()
            return hl.dsp.window.move({ direction = "down" })
        end,
        options = {
            description = "Move Window Down",
        },
    },
    -- Window resizing and pointer actions
    {
        key = kb.shrinkWidth,
        fallback_key = registry.default_key("shrinkWidth"),
        build_action = function()
            return fn.resize_active(-10, 0)
        end,
        options = {
            repeating = true,
            description = "Shrink Window Width",
        },
    },
    {
        key = kb.expandWidth,
        fallback_key = registry.default_key("expandWidth"),
        build_action = function()
            return fn.resize_active(10, 0)
        end,
        options = {
            repeating = true,
            description = "Expand Window Width",
        },
    },
    {
        key = kb.shrinkHeight,
        fallback_key = registry.default_key("shrinkHeight"),
        build_action = function()
            return fn.resize_active(0, -10)
        end,
        options = {
            repeating = true,
            description = "Shrink Window Height",
        },
    },
    {
        key = kb.expandHeight,
        fallback_key = registry.default_key("expandHeight"),
        build_action = function()
            return fn.resize_active(0, 10)
        end,
        options = {
            repeating = true,
            description = "Expand Window Height",
        },
    },
    {
        key = kb.shrinkWidthAlt,
        fallback_key = registry.default_key("shrinkWidthAlt"),
        build_action = function()
            return fn.resize_active(-10, 0)
        end,
        options = {
            repeating = true,
            description = "Shrink Window Width",
        },
    },
    {
        key = kb.expandWidthAlt,
        fallback_key = registry.default_key("expandWidthAlt"),
        build_action = function()
            return fn.resize_active(10, 0)
        end,
        options = {
            repeating = true,
            description = "Expand Window Width",
        },
    },
    {
        key = kb.shrinkHeightAlt,
        fallback_key = registry.default_key("shrinkHeightAlt"),
        build_action = function()
            return fn.resize_active(0, -10)
        end,
        options = {
            repeating = true,
            description = "Shrink Window Height",
        },
    },
    {
        key = kb.expandHeightAlt,
        fallback_key = registry.default_key("expandHeightAlt"),
        build_action = function()
            return fn.resize_active(0, 10)
        end,
        options = {
            repeating = true,
            description = "Expand Window Height",
        },
    },
    {
        key = kb.dragWindow,
        fallback_key = registry.default_key("dragWindow"),
        build_action = function()
            return hl.dsp.window.drag()
        end,
        options = {
            mouse = true,
            description = "Move Window Using Mouse",
        },
    },
    {
        key = kb.resizeWindowMouse,
        fallback_key = registry.default_key("resizeWindowMouse"),
        build_action = function()
            return hl.dsp.window.resize()
        end,
        options = {
            mouse = true,
            description = "Resize Window Using Mouse",
        },
    },
    {
        key = kb.centerWindow,
        fallback_key = registry.default_key("centerWindow"),
        build_action = function()
            return hl.dsp.window.center()
        end,
        options = {
            description = "Move Window to Screen Center",
        },
    },
    {
        key = kb.resizeWindowToScreen,
        fallback_key = registry.default_key("resizeWindowToScreen"),
        build_action = function()
            return fn.resize_screen(55, 70)
        end,
        options = {
            description = "Resize Window to 55x70 Percent of Screen",
        },
    },
    -- Window modes and layouts
    {
        key = kb.pictureInPicture,
        fallback_key = registry.default_key("pictureInPicture"),
        build_action = function()
            return fn.toggle_pip
        end,
        options = {
            description = "Toggle Picture-in-Picture Mode",
        },
    },
    {
        key = kb.pinWindow,
        fallback_key = registry.default_key("pinWindow"),
        build_action = function()
            return hl.dsp.window.pin()
        end,
        options = {
            description = "Pin/Unpin Window",
        },
    },
    {
        key = kb.pseudotileWindow,
        fallback_key = registry.default_key("pseudotileWindow"),
        build_action = function()
            return hl.dsp.window.pseudo()
        end,
        options = {
            description = "Toggle Pseudotiled Mode",
        },
    },
    {
        key = kb.fullscreenWindow,
        fallback_key = registry.default_key("fullscreenWindow"),
        build_action = function()
            return hl.dsp.window.fullscreen({ mode = "fullscreen" })
        end,
        options = {
            description = "Toggle Fullscreen Mode",
        },
    },
    {
        key = kb.maximizedWindow,
        fallback_key = registry.default_key("maximizedWindow"),
        build_action = function()
            return hl.dsp.window.fullscreen({ mode = "maximized" })
        end,
        options = {
            description = "Toggle Maximized Mode",
        },
    },
    {
        key = kb.toggleFloating,
        fallback_key = registry.default_key("toggleFloating"),
        build_action = function()
            return fn.toggle_floating
        end,
        options = {
            description = "Toggle Floating Mode",
        },
    },
    {
        key = kb.closeWindow,
        fallback_key = registry.default_key("closeWindow"),
        build_action = function()
            return hl.dsp.window.close()
        end,
        options = {
            description = "Close Active Window",
        },
    },
    {
        key = kb.cycleWorkspaceLayout,
        fallback_key = registry.default_key("cycleWorkspaceLayout"),
        build_action = function()
            return fn.cycle_all_layouts
        end,
        options = {
            description = "Cycle Workspace Layout (All Types)",
        },
    },
    {
        key = kb.toggleScrollLayout,
        fallback_key = registry.default_key("toggleScrollLayout"),
        build_action = function()
            return fn.toggle_scroll_layout
        end,
        options = {
            description = "Toggle between Dwindle and Scrolling Layout",
        },
    },
    -- Applications
    {
        key = kb.terminal,
        fallback_key = registry.default_key("terminal"),
        build_action = function()
            return hl.dsp.exec_cmd(vars.terminal)
        end,
        options = {
            description = "Launch Default Terminal",
        },
    },
    {
        key = kb.browser,
        fallback_key = registry.default_key("browser"),
        build_action = function()
            return hl.dsp.exec_cmd(vars.browser)
        end,
        options = {
            description = "Launch Default Web Browser",
        },
    },
    {
        key = kb.editor,
        fallback_key = registry.default_key("editor"),
        build_action = function()
            return hl.dsp.exec_cmd(vars.editor)
        end,
        options = {
            description = "Launch Default Text Editor",
        },
    },
    {
        key = kb.fileExplorer,
        fallback_key = registry.default_key("fileExplorer"),
        build_action = function()
            return hl.dsp.exec_cmd(vars.fileExplorer)
        end,
        options = {
            description = "Launch Default File Manager",
        },
    },
    {
        key = kb.audioMixer,
        fallback_key = registry.default_key("audioMixer"),
        build_action = function()
            return hl.dsp.exec_cmd(vars.audioSettings)
        end,
        options = {
            description = "Launch Volume Mixer",
        },
    },
    {
        key = kb.floatingTerminal,
        fallback_key = registry.default_key("floatingTerminal"),
        build_action = function()
            return hl.dsp.exec_cmd(vars.terminal, fn.floatSpawnRule(vars.terminal, { float = true }))
        end,
        options = {
            description = "Launch Terminal in (Floating)",
        },
    },
    {
        key = kb.floatingBrowser,
        fallback_key = registry.default_key("floatingBrowser"),
        build_action = function()
            return hl.dsp.exec_cmd(vars.browser, fn.floatSpawnRule(vars.browser, { float = true }))
        end,
        options = {
            description = "Launch Web Browser in (Floating)",
        },
    },
    {
        key = kb.floatingEditor,
        fallback_key = registry.default_key("floatingEditor"),
        build_action = function()
            return hl.dsp.exec_cmd(vars.editor, fn.floatSpawnRule(vars.editor, { float = true }))
        end,
        options = {
            description = "Launch Text Editor in (Floating)",
        },
    },
    {
        key = kb.floatingFileExplorer,
        fallback_key = registry.default_key("floatingFileExplorer"),
        build_action = function()
            return hl.dsp.exec_cmd(vars.fileExplorer, fn.floatSpawnRule(vars.fileExplorer, { float = true }))
        end,
        options = {
            description = "Launch File Manager in (Floating)",
        },
    },
    {
        key = kb.pseudotiledTerminal,
        fallback_key = registry.default_key("pseudotiledTerminal"),
        build_action = function()
            return hl.dsp.exec_cmd(vars.terminal, fn.floatSpawnRule(vars.terminal, { pseudo = true }))
        end,
        options = {
            description = "Launch Terminal in (Pseudotiled)",
        },
    },
    {
        key = kb.colorPicker,
        fallback_key = registry.default_key("colorPicker"),
        build_action = function()
            return hl.dsp.exec_cmd("hyprpicker -a")
        end,
        options = {
            description = "Launch Color Picker",
        },
    },
    -- Audio
    {
        key = kb.microphoneMute,
        fallback_key = registry.default_key("microphoneMute"),
        build_action = function()
            return hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle")
        end,
        options = {
            locked = true,
            description = "Toggle Microphone Mute",
        },
    },
    {
        key = kb.audioMute,
        fallback_key = registry.default_key("audioMute"),
        build_action = function()
            return hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")
        end,
        options = {
            locked = true,
            description = "Toggle Audio Mute",
        },
    },
    {
        key = kb.audioMuteAlt,
        fallback_key = registry.default_key("audioMuteAlt"),
        build_action = function()
            return hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")
        end,
        options = {
            locked = true,
            description = "Toggle Audio Mute",
        },
    },
    {
        key = kb.volumeUp,
        fallback_key = registry.default_key("volumeUp"),
        build_action = function()
            return hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; wpctl set-volume -l " .. (vars.volumeMax / 100) .. " @DEFAULT_AUDIO_SINK@ " .. vars.volumeStep .. "%+")
        end,
        options = {
            locked = true,
            repeating = true,
            description = "Increase Audio Volume",
        },
    },
    {
        key = kb.volumeDown,
        fallback_key = registry.default_key("volumeDown"),
        build_action = function()
            return hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; wpctl set-volume @DEFAULT_AUDIO_SINK@ " .. vars.volumeStep .. "%-")
        end,
        options = {
            locked = true,
            repeating = true,
            description = "Decrease Audio Volume",
        },
    },
    -- Brightness and keyboard backlight
    {
        key = kb.brightnessUp,
        fallback_key = registry.default_key("brightnessUp"),
        build_action = function()
            return hl.dsp.exec_cmd("brightnessctl s 5%+")
        end,
        options = {
            locked = true,
            description = "Increase Display Brightness",
        },
    },
    {
        key = kb.brightnessDown,
        fallback_key = registry.default_key("brightnessDown"),
        build_action = function()
            return hl.dsp.exec_cmd("brightnessctl s 5%-")
        end,
        options = {
            locked = true,
            description = "Decrease Display Brightness",
        },
    },
    {
        key = kb.keyboardBacklightUp,
        fallback_key = registry.default_key("keyboardBacklightUp"),
        build_action = function()
            return hl.dsp.exec_cmd("brightnessctl -d platform::kbd_backlight set +1")
        end,
        options = {
            description = "Increase Keyboard Backlight",
        },
    },
    {
        key = kb.keyboardBacklightDown,
        fallback_key = registry.default_key("keyboardBacklightDown"),
        build_action = function()
            return hl.dsp.exec_cmd("brightnessctl -d platform::kbd_backlight set 1-")
        end,
        options = {
            description = "Decrease Keyboard Backlight",
        },
    },
    -- Media playback
    {
        key = kb.mediaPlay,
        fallback_key = registry.default_key("mediaPlay"),
        build_action = function()
            return hl.dsp.exec_cmd("playerctl play-pause")
        end,
        options = {
            locked = true,
            description = "Toggle Play/Pause",
        },
    },
    {
        key = kb.mediaPause,
        fallback_key = registry.default_key("mediaPause"),
        build_action = function()
            return hl.dsp.exec_cmd("playerctl play-pause")
        end,
        options = {
            locked = true,
            description = "Toggle Play/Pause",
        },
    },
    {
        key = kb.mediaPlayAlt,
        fallback_key = registry.default_key("mediaPlayAlt"),
        build_action = function()
            return hl.dsp.exec_cmd("playerctl play-pause")
        end,
        options = {
            description = "Toggle Play/Pause",
        },
    },
    {
        key = kb.mediaNext,
        fallback_key = registry.default_key("mediaNext"),
        build_action = function()
            return hl.dsp.exec_cmd(nextTrack)
        end,
        options = {
            locked = true,
            description = "Play Next Track",
        },
    },
    {
        key = kb.mediaNextAlt,
        fallback_key = registry.default_key("mediaNextAlt"),
        build_action = function()
            return hl.dsp.exec_cmd(nextTrack)
        end,
        options = {
            locked = true,
            description = "Play Next Track",
        },
    },
    {
        key = kb.mediaNextAlt2,
        fallback_key = registry.default_key("mediaNextAlt2"),
        build_action = function()
            return hl.dsp.exec_cmd(nextTrack)
        end,
        options = {
            description = "Play Next Track",
        },
    },
    {
        key = kb.mediaPrevious,
        fallback_key = registry.default_key("mediaPrevious"),
        build_action = function()
            return hl.dsp.exec_cmd("playerctl previous")
        end,
        options = {
            locked = true,
            description = "Play Previous Track",
        },
    },
    {
        key = kb.mediaPreviousAlt,
        fallback_key = registry.default_key("mediaPreviousAlt"),
        build_action = function()
            return hl.dsp.exec_cmd("playerctl previous")
        end,
        options = {
            locked = true,
            description = "Play Previous Track",
        },
    },
    {
        key = kb.mediaPreviousAlt2,
        fallback_key = registry.default_key("mediaPreviousAlt2"),
        build_action = function()
            return hl.dsp.exec_cmd("playerctl previous")
        end,
        options = {
            description = "Play Previous Track",
        },
    },
    {
        key = kb.mediaStop,
        fallback_key = registry.default_key("mediaStop"),
        build_action = function()
            return hl.dsp.exec_cmd("playerctl stop")
        end,
        options = {
            locked = true,
            description = "Stop Playback",
        },
    },
}
-- Numbered workspace bindings are generated because each action uses the
-- workspace index while the physical key for workspace 10 is 0.
for i = 1, 10 do
    local key = i % 10
    bindings[#bindings + 1] = {
        key = registry.workspace_key(kb.goToWorkspacePrefix, key),
        fallback_key = registry.workspace_key(registry.default_key("goToWorkspacePrefix"), key),
        build_action = function()
            return fn.wsaction("focus", "", i)
        end,
        options = {
            description = "Focus Workspace " .. i,
        },
    }
    bindings[#bindings + 1] = {
        key = registry.workspace_key(kb.moveWindowToWorkspacePrefix, key),
        fallback_key = registry.workspace_key(registry.default_key("moveWindowToWorkspacePrefix"), key),
        build_action = function()
            return fn.wsaction("move", "", i)
        end,
        options = {
            description = "Workspaces: Move Window to Workspace " .. i,
        },
    }
    bindings[#bindings + 1] = {
        key = registry.workspace_key(kb.goToWorkspaceGroupPrefix, key),
        fallback_key = registry.workspace_key(registry.default_key("goToWorkspaceGroupPrefix"), key),
        build_action = function()
            return fn.wsaction("focus", "group", i)
        end,
        options = {
            description = "Focus Workspace Group " .. i,
        },
    }
    bindings[#bindings + 1] = {
        key = registry.workspace_key(kb.moveWindowToWorkspaceGroupPrefix, key),
        fallback_key = registry.workspace_key(registry.default_key("moveWindowToWorkspaceGroupPrefix"), key),
        build_action = function()
            return fn.wsaction("move", "group", i)
        end,
        options = {
            description = "Move Window to Workspace Group " .. i,
        },
    }
end
-- Custom replacements are attempted first; a failure retains the default.
return registry.register(bindings, function()
    return require("custom.keybinds")
end)
