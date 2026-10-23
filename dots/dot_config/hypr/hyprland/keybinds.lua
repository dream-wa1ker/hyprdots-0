-- ~/.config/hypr/hyprland/keybinds.lua
-- Declarative keybinding registry. All shortcut strings live in variables.lua.
local vars = require("hyprland.variables")
local fn = require("hyprland.functions")
local kb = vars.keybinds
local noctalia = fn.noctalia
local recorder = "noctalia msg plugin h-jangra/region-recorder:service all "
local nextTrack = 'playerctl next || playerctl position `bc <<< "100 * $(playerctl metadata mpris:length) / 1000000 / 100"`'
local bindings = {
    -- Noctalia / shell
    {
        key = kb.launcher,
        action = noctalia("panel-toggle launcher"),
        options = {
            description = "Toggle Launcher / Search",
        },
    },
    {
        key = kb.keybindCheatsheet,
        action = noctalia("panel-toggle blackbartblues/keymap:panel"),
        options = {
            description = "View Keybindings Cheatsheet",
        },
    },
    {
        key = kb.clipboard,
        action = noctalia("panel-toggle clipboard"),
        options = {
            description = "Toggle Clipboard History",
        },
    },
    {
        key = kb.emojiSearch,
        action = noctalia('panel-toggle launcher "/emo "'),
        options = {
            description = "Toggle Emoji Searcher",
        },
    },
    {
        key = kb.shellPanelSelector,
        action = noctalia('panel-toggle launcher "/"'),
        options = {
            description = "Toggle Shell Panel Selector",
        },
    },
    {
        key = kb.windowSwitcher,
        action = noctalia("window-switcher hold"),
        options = {
            description = "Toggle Window Switcher",
        },
    },
    {
        key = kb.dashboard,
        action = noctalia("panel-toggle control-center"),
        options = {
            description = "Toggle Main Dashboard",
        },
    },
    {
        key = kb.notifications,
        action = noctalia("panel-toggle control-center notifications"),
        options = {
            description = "Toggle Notifications Panel",
        },
    },
    {
        key = kb.mediaPanel,
        action = noctalia("panel-toggle control-center media"),
        options = {
            description = "Toggle Media Panel",
        },
    },
    {
        key = kb.barToggle,
        action = noctalia("bar-toggle default"),
        options = {
            description = "Toggle the Visibility of Default Bar",
        },
    },
    {
        key = kb.sessionPanel,
        action = noctalia("panel-toggle session"),
        options = {
            description = "Toggle Session Panel",
        },
    },
    {
        key = kb.lockScreen,
        action = noctalia("session lock"),
        options = {
            description = "Activate Lock Screen",
        },
    },
    {
        key = kb.reloadNoctalia,
        action = noctalia("config-reload"),
        options = {
            release = true,
            description = "Reload Noctalia Configuration",
        },
    },
    {
        key = kb.suspend,
        action = noctalia("session lock-and-suspend"),
        options = {
            locked = true,
            description = "Session: Lock and Suspend",
        },
    },
    {
        key = kb.archUpdater,
        action = noctalia("panel-toggle yuuto/arch-updater:panel"),
        options = {
            description = "View Pending Arch System Updates",
        },
    },
    {
        key = kb.pomodoro,
        action = noctalia("panel-toggle thepunkoff/pomodoro:panel"),
        options = {
            description = "Toggle Focus Pomodoro",
        },
    },
    {
        key = kb.notes,
        action = noctalia("panel-toggle noctalia/notes:panel"),
        options = {
            description = "Open Notes Side Bar",
        },
    },
    {
        key = kb.liveAnnotation,
        action = noctalia("annotate"),
        options = {
            description = "Activate Live Screen Annotation",
        },
    },
    {
        key = kb.ocrRegion,
        action = noctalia("plugin fel/ocr:ocr all ocr-region"),
        options = {
            description = "OCR Selector for a Region",
        },
    },
    {
        key = kb.frozenAnnotation,
        action = noctalia("screenshot-annotate"),
        options = {
            description = "Activate Frozen Screen Annotation",
        },
    },
    {
        key = kb.ocrFullscreen,
        action = noctalia("plugin fel/ocr:ocr all ocr-screen"),
        options = {
            description = "OCR Selector for Fullscreen",
        },
    },
    {
        key = kb.recordFullscreen,
        action = hl.dsp.exec_cmd(recorder .. "record-fullscreen"),
        options = {
            description = "Recording: Start Fullscreen (Audio)",
        },
    },
    {
        key = kb.recordRegion,
        action = hl.dsp.exec_cmd(recorder .. "select-region"),
        options = {
            description = "Recording: Select Region (Audio)",
        },
    },
    {
        key = kb.stopRecording,
        action = hl.dsp.exec_cmd(recorder .. "stop"),
        options = {
            description = "Recording: Stop",
        },
    },
    {
        key = kb.screenshotRegion,
        action = noctalia("screenshot-region"),
        options = {
            description = "Screenshot: Region",
        },
    },
    {
        key = kb.screenshotClipboard,
        action = hl.dsp.exec_cmd('grim -o "$(hyprctl activeworkspace -j | jq -r \'.monitor\')" - | wl-copy && notify-send -u low "Screenshot" "Monitor screenshot copied to clipboard"'),
        options = {
            locked = true,
            description = "Copy Monitor Screenshot to Clipboard",
        },
    },
    {
        key = kb.screenshotSave,
        action = hl.dsp.exec_cmd('mkdir -p "$(xdg-user-dir PICTURES)/Screenshots" && grim -o "$(hyprctl activeworkspace -j | jq -r \'.monitor\')" "$(xdg-user-dir PICTURES)/Screenshots/Screenshot_$(date \'+%Y-%m-%d_%H.%M.%S\').png" && notify-send -u low "Screenshot" "Monitor screenshot saved to Pictures/Screenshots"'),
        options = {
            description = "Save Monitor Screenshot",
        },
    },
    {
        key = kb.noctaliaProfileSwitcher,
        action = hl.dsp.exec_cmd('bash ~/Projects/hyprdots-0/scripts/profile-switch'),
        options = {
            description = "Save Monitor Screenshot",
        },
    },

    {
        key = kb.wallpaperSelector,
        action = noctalia("panel-toggle wallpaper"),
        options = {
            description = "Toggle Wallpaper Selector",
        },
    },
    {
        key = kb.randomWallpaper,
        action = noctalia("wallpaper-random"),
        options = {
            description = "Set Random Wallpaper",
        },
    },
    {
        key = kb.noctaliaSettings,
        action = noctalia("settings-toggle"),
        options = {
            description = "Launch Noctalia Settings",
        },
    },
    -- Workspace navigation and movement (non-numbered)
    {
        key = kb.previousWorkspaceMouse,
        action = hl.dsp.focus({ workspace = "-1" }),
        options = {
            description = "Focus Previous Workspace",
        },
    },
    {
        key = kb.nextWorkspaceMouse,
        action = hl.dsp.focus({ workspace = "+1" }),
        options = {
            description = "Focus Next Workspace",
        },
    },
    {
        key = kb.previousWorkspace,
        action = hl.dsp.focus({ workspace = "-1" }),
        options = {
            repeating = true,
            description = "Focus Previous Workspace",
        },
    },
    {
        key = kb.nextWorkspace,
        action = hl.dsp.focus({ workspace = "+1" }),
        options = {
            repeating = true,
            description = "Focus Next Workspace",
        },
    },
    {
        key = kb.moveWindowPreviousWorkspace,
        action = hl.dsp.window.move({ workspace = "-1" }),
        options = {
            repeating = true,
            description = "Move Window to Previous Workspace",
        },
    },
    {
        key = kb.moveWindowNextWorkspace,
        action = hl.dsp.window.move({ workspace = "+1" }),
        options = {
            repeating = true,
            description = "Move Window to Next Workspace",
        },
    },
    {
        key = kb.moveWindowPreviousWorkspaceMouse,
        action = hl.dsp.window.move({ workspace = "-1" }),
        options = {
            description = "Move Window to Previous Workspace",
        },
    },
    {
        key = kb.moveWindowNextWorkspaceMouse,
        action = hl.dsp.window.move({ workspace = "+1" }),
        options = {
            description = "Move Window to Next Workspace",
        },
    },
    {
        key = kb.previousWorkspaceGroup,
        action = hl.dsp.focus({ workspace = "-10" }),
        options = {
            repeating = true,
            description = "Focus Previous Workspace Group",
        },
    },
    {
        key = kb.nextWorkspaceGroup,
        action = hl.dsp.focus({ workspace = "+10" }),
        options = {
            repeating = true,
            description = "Focus Next Workspace Group",
        },
    },
    {
        key = kb.previousWorkspaceGroupMouse,
        action = hl.dsp.focus({ workspace = "-10" }),
        options = {
            description = "Focus Previous Workspace Group",
        },
    },
    {
        key = kb.nextWorkspaceGroupMouse,
        action = hl.dsp.focus({ workspace = "+10" }),
        options = {
            description = "Focus Next Workspace Group",
        },
    },
    {
        key = kb.moveWindowNextWorkspaceGroup,
        action = hl.dsp.window.move({ workspace = "+10" }),
        options = {
            repeating = true,
            description = "Move Window to Next Workspace Group",
        },
    },
    {
        key = kb.moveWindowPreviousWorkspaceGroup,
        action = hl.dsp.window.move({ workspace = "-10" }),
        options = {
            repeating = true,
            description = "Move Window to Previous Workspace Group",
        },
    },
    -- Named special workspaces
    {
        key = kb.specialWorkspace,
        action = hl.dsp.workspace.toggle_special("special"),
        options = {
            description = "Toggle Special Workspace",
        },
    },
    {
        key = kb.sysmonWorkspace,
        action = hl.dsp.workspace.toggle_special("sysmon"),
        options = {
            description = "Toggle Sysmon Workspace",
        },
    },
    {
        key = kb.communicationWorkspace,
        action = hl.dsp.workspace.toggle_special("communication"),
        options = {
            description = "Toggle Communication Workspace",
        },
    },
    {
        key = kb.moveWindowToSpecialWorkspace,
        action = hl.dsp.window.move({ workspace = "special:special" }),
        options = {
            description = "Move Window to Special Workspace",
        },
    },
    {
        key = kb.moveWindowOutOfSpecialWorkspace,
        action = hl.dsp.window.move({ workspace = "e+0" }),
        options = {
            description = "Move Window Out of Special Workspace",
        },
    },
    -- Window grouping
    {
        key = kb.toggleGroup,
        action = hl.dsp.group.toggle(),
        options = {
            description = "Toggle Window Grouping",
        },
    },
    {
        key = kb.ungroupWindow,
        action = hl.dsp.window.move({ out_of_group = true }),
        options = {
            description = "Move Window Out of Group",
        },
    },
    {
        key = kb.lockActiveGroup,
        action = hl.dsp.group.lock_active(),
        options = {
            description = "Lock Active Group",
        },
    },
    {
        key = kb.nextWindowInGroup,
        action = hl.dsp.window.cycle_next(),
        options = {
            repeating = true,
            description = "Focus Next Window in Group",
        },
    },
    {
        key = kb.previousWindowInGroup,
        action = hl.dsp.window.cycle_next({ next = false }),
        options = {
            repeating = true,
            description = "Focus Previous Window in Group",
        },
    },
    {
        key = kb.nextGroupWindow,
        action = hl.dsp.group.next(),
        options = {
            repeating = true,
            description = "Switch to Next Group Window",
        },
    },
    {
        key = kb.previousGroupWindow,
        action = hl.dsp.group.prev(),
        options = {
            repeating = true,
            description = "Switch to Previous Group Window",
        },
    },
    -- Window focus and movement
    {
        key = kb.focusLeft,
        action = hl.dsp.focus({ direction = "left" }),
        options = {
            description = "Focus Left Window",
        },
    },
    {
        key = kb.focusRight,
        action = hl.dsp.focus({ direction = "right" }),
        options = {
            description = "Focus Right Window",
        },
    },
    {
        key = kb.focusUp,
        action = hl.dsp.focus({ direction = "up" }),
        options = {
            description = "Focus Up Window",
        },
    },
    {
        key = kb.focusDown,
        action = hl.dsp.focus({ direction = "down" }),
        options = {
            description = "Focus Down Window",
        },
    },
    {
        key = kb.moveLeft,
        action = hl.dsp.window.move({ direction = "left" }),
        options = {
            description = "Move Window Left",
        },
    },
    {
        key = kb.moveRight,
        action = hl.dsp.window.move({ direction = "right" }),
        options = {
            description = "Move Window Right",
        },
    },
    {
        key = kb.moveUp,
        action = hl.dsp.window.move({ direction = "up" }),
        options = {
            description = "Move Window Up",
        },
    },
    {
        key = kb.moveDown,
        action = hl.dsp.window.move({ direction = "down" }),
        options = {
            description = "Move Window Down",
        },
    },
    -- Window resizing and pointer actions
    {
        key = kb.shrinkWidth,
        action = fn.resize_active(-10, 0),
        options = {
            repeating = true,
            description = "Shrink Window Width",
        },
    },
    {
        key = kb.expandWidth,
        action = fn.resize_active(10, 0),
        options = {
            repeating = true,
            description = "Expand Window Width",
        },
    },
    {
        key = kb.shrinkHeight,
        action = fn.resize_active(0, -10),
        options = {
            repeating = true,
            description = "Shrink Window Height",
        },
    },
    {
        key = kb.expandHeight,
        action = fn.resize_active(0, 10),
        options = {
            repeating = true,
            description = "Expand Window Height",
        },
    },
    {
        key = kb.shrinkWidthAlt,
        action = fn.resize_active(-10, 0),
        options = {
            repeating = true,
            description = "Shrink Window Width",
        },
    },
    {
        key = kb.expandWidthAlt,
        action = fn.resize_active(10, 0),
        options = {
            repeating = true,
            description = "Expand Window Width",
        },
    },
    {
        key = kb.shrinkHeightAlt,
        action = fn.resize_active(0, -10),
        options = {
            repeating = true,
            description = "Shrink Window Height",
        },
    },
    {
        key = kb.expandHeightAlt,
        action = fn.resize_active(0, 10),
        options = {
            repeating = true,
            description = "Expand Window Height",
        },
    },
    {
        key = kb.dragWindow,
        action = hl.dsp.window.drag(),
        options = {
            mouse = true,
            description = "Move Window Using Mouse",
        },
    },
    {
        key = kb.resizeWindowMouse,
        action = hl.dsp.window.resize(),
        options = {
            mouse = true,
            description = "Resize Window Using Mouse",
        },
    },
    {
        key = kb.centerWindow,
        action = hl.dsp.window.center(),
        options = {
            description = "Move Window to Screen Center",
        },
    },
    {
        key = kb.resizeWindowToScreen,
        action = fn.resize_screen(55, 70),
        options = {
            description = "Resize Window to 55x70 Percent of Screen",
        },
    },
    -- Window modes and layouts
    {
        key = kb.pictureInPicture,
        action = fn.toggle_pip,
        options = {
            description = "Toggle Picture-in-Picture Mode",
        },
    },
    {
        key = kb.pinWindow,
        action = hl.dsp.window.pin(),
        options = {
            description = "Pin/Unpin Window",
        },
    },
    {
        key = kb.pseudotileWindow,
        action = hl.dsp.window.pseudo(),
        options = {
            description = "Toggle Pseudotiled Mode",
        },
    },
    {
        key = kb.fullscreenWindow,
        action = hl.dsp.window.fullscreen({ mode = "fullscreen" }),
        options = {
            description = "Toggle Fullscreen Mode",
        },
    },
    {
        key = kb.maximizedWindow,
        action = hl.dsp.window.fullscreen({ mode = "maximized" }),
        options = {
            description = "Toggle Maximized Mode",
        },
    },
    {
        key = kb.toggleFloating,
        action = fn.toggle_floating,
        options = {
            description = "Toggle Floating Mode",
        },
    },
    {
        key = kb.closeWindow,
        action = hl.dsp.window.close(),
        options = {
            description = "Close Active Window",
        },
    },
    {
        key = kb.cycleWorkspaceLayout,
        action = fn.cycle_all_layouts,
        options = {
            description = "Cycle Workspace Layout (All Types)",
        },
    },
    {
        key = kb.toggleScrollLayout,
        action = fn.toggle_scroll_layout,
        options = {
            description = "Toggle between Dwindle and Scrolling Layout",
        },
    },
    -- Applications
    {
        key = kb.terminal,
        action = hl.dsp.exec_cmd(vars.terminal),
        options = {
            description = "Launch Default Terminal",
        },
    },
    {
        key = kb.browser,
        action = hl.dsp.exec_cmd(vars.browser),
        options = {
            description = "Launch Default Web Browser",
        },
    },
    {
        key = kb.editor,
        action = hl.dsp.exec_cmd(vars.editor),
        options = {
            description = "Launch Default Text Editor",
        },
    },
    {
        key = kb.fileExplorer,
        action = hl.dsp.exec_cmd(vars.fileExplorer),
        options = {
            description = "Launch Default File Manager",
        },
    },
    {
        key = kb.audioMixer,
        action = hl.dsp.exec_cmd(vars.audioSettings),
        options = {
            description = "Launch Volume Mixer",
        },
    },
    {
        key = kb.floatingTerminal,
        action = hl.dsp.exec_cmd(vars.terminal, fn.floatSpawnRule(vars.terminal, { float = true })),
        options = {
            description = "Launch Terminal in (Floating)",
        },
    },
    {
        key = kb.floatingBrowser,
        action = hl.dsp.exec_cmd(vars.browser, fn.floatSpawnRule(vars.browser, { float = true })),
        options = {
            description = "Launch Web Browser in (Floating)",
        },
    },
    {
        key = kb.floatingEditor,
        action = hl.dsp.exec_cmd(vars.editor, fn.floatSpawnRule(vars.editor, { float = true })),
        options = {
            description = "Launch Text Editor in (Floating)",
        },
    },
    {
        key = kb.floatingFileExplorer,
        action = hl.dsp.exec_cmd(vars.fileExplorer, fn.floatSpawnRule(vars.fileExplorer, { float = true })),
        options = {
            description = "Launch File Manager in (Floating)",
        },
    },
    {
        key = kb.pseudotiledTerminal,
        action = hl.dsp.exec_cmd(vars.terminal, fn.floatSpawnRule(vars.terminal, { pseudo = true })),
        options = {
            description = "Launch Terminal in (Pseudotiled)",
        },
    },
    {
        key = kb.colorPicker,
        action = hl.dsp.exec_cmd("hyprpicker -a"),
        options = {
            description = "Launch Color Picker",
        },
    },
    -- Audio
    {
        key = kb.microphoneMute,
        action = hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
        options = {
            locked = true,
            description = "Toggle Microphone Mute",
        },
    },
    {
        key = kb.audioMute,
        action = hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
        options = {
            locked = true,
            description = "Toggle Audio Mute",
        },
    },
    {
        key = kb.audioMuteAlt,
        action = hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
        options = {
            locked = true,
            description = "Toggle Audio Mute",
        },
    },
    {
        key = kb.volumeUp,
        action = hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; wpctl set-volume -l " .. (vars.volumeMax / 100) .. " @DEFAULT_AUDIO_SINK@ " .. vars.volumeStep .. "%+"),
        options = {
            locked = true,
            repeating = true,
            description = "Increase Audio Volume",
        },
    },
    {
        key = kb.volumeDown,
        action = hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; wpctl set-volume @DEFAULT_AUDIO_SINK@ " .. vars.volumeStep .. "%-"),
        options = {
            locked = true,
            repeating = true,
            description = "Decrease Audio Volume",
        },
    },
    -- Brightness and keyboard backlight
    {
        key = kb.brightnessUp,
        action = hl.dsp.exec_cmd("brightnessctl s 5%+"),
        options = {
            locked = true,
            description = "Increase Display Brightness",
        },
    },
    {
        key = kb.brightnessDown,
        action = hl.dsp.exec_cmd("brightnessctl s 5%-"),
        options = {
            locked = true,
            description = "Decrease Display Brightness",
        },
    },
    {
        key = kb.keyboardBacklightUp,
        action = hl.dsp.exec_cmd("brightnessctl -d platform::kbd_backlight set +1"),
        options = {
            description = "Increase Keyboard Backlight",
        },
    },
    {
        key = kb.keyboardBacklightDown,
        action = hl.dsp.exec_cmd("brightnessctl -d platform::kbd_backlight set 1-"),
        options = {
            description = "Decrease Keyboard Backlight",
        },
    },
    -- Media playback
    {
        key = kb.mediaPlay,
        action = hl.dsp.exec_cmd("playerctl play-pause"),
        options = {
            locked = true,
            description = "Toggle Play/Pause",
        },
    },
    {
        key = kb.mediaPause,
        action = hl.dsp.exec_cmd("playerctl play-pause"),
        options = {
            locked = true,
            description = "Toggle Play/Pause",
        },
    },
    {
        key = kb.mediaPlayAlt,
        action = hl.dsp.exec_cmd("playerctl play-pause"),
        options = {
            description = "Toggle Play/Pause",
        },
    },
    {
        key = kb.mediaNext,
        action = hl.dsp.exec_cmd(nextTrack),
        options = {
            locked = true,
            description = "Play Next Track",
        },
    },
    {
        key = kb.mediaNextAlt,
        action = hl.dsp.exec_cmd(nextTrack),
        options = {
            locked = true,
            description = "Play Next Track",
        },
    },
    {
        key = kb.mediaNextAlt2,
        action = hl.dsp.exec_cmd(nextTrack),
        options = {
            description = "Play Next Track",
        },
    },
    {
        key = kb.mediaPrevious,
        action = hl.dsp.exec_cmd("playerctl previous"),
        options = {
            locked = true,
            description = "Play Previous Track",
        },
    },
    {
        key = kb.mediaPreviousAlt,
        action = hl.dsp.exec_cmd("playerctl previous"),
        options = {
            locked = true,
            description = "Play Previous Track",
        },
    },
    {
        key = kb.mediaPreviousAlt2,
        action = hl.dsp.exec_cmd("playerctl previous"),
        options = {
            description = "Play Previous Track",
        },
    },
    {
        key = kb.mediaStop,
        action = hl.dsp.exec_cmd("playerctl stop"),
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
        key = kb.goToWorkspacePrefix .. " + " .. key,
        action = fn.wsaction("focus", "", i),
        options = {
            description = "Focus Workspace " .. i,
        },
    }
    bindings[#bindings + 1] = {
        key = kb.moveWindowToWorkspacePrefix .. " + " .. key,
        action = fn.wsaction("move", "", i),
        options = {
            description = "Workspaces: Move Window to Workspace " .. i,
        },
    }
    bindings[#bindings + 1] = {
        key = kb.goToWorkspaceGroupPrefix .. " + " .. key,
        action = fn.wsaction("focus", "group", i),
        options = {
            description = "Focus Workspace Group " .. i,
        },
    }
    bindings[#bindings + 1] = {
        key = kb.moveWindowToWorkspaceGroupPrefix .. " + " .. key,
        action = fn.wsaction("move", "group", i),
        options = {
            description = "Move Window to Workspace Group " .. i,
        },
    }
end
-- Custom bindings are declarative so they can override defaults before registration.
-- A problem never aborts registration: it is collected, logged, and reported once.
local problems = {}
local function report(message)
    problems[#problems + 1] = message
    print("[Hyprland config] keybinds: " .. message)
end

local ok, customBindings = pcall(require, "custom.keybinds")
if not ok then
    -- A missing custom module is normal; a syntax/runtime error is reported.
    if not tostring(customBindings):match("module 'custom%.keybinds' not found") then
        report("custom.keybinds failed to load: " .. tostring(customBindings))
    end
    customBindings = {}
end
-- An empty (or all-comment) file makes require() return `true`, not a table.
if type(customBindings) ~= "table" then customBindings = {} end

local function normalizeKey(key)
    local parts = {}
    for part in tostring(key):gmatch("[^+]+") do
        local cleaned = part:gsub("^%s+", ""):gsub("%s+$", ""):lower()
        if cleaned ~= "" then parts[#parts + 1] = cleaned end
    end
    table.sort(parts)
    return table.concat(parts, "+")
end

-- Validate custom entries; the first one wins on a duplicate.
local customKeys, validCustom = {}, {}
for i, entry in ipairs(customBindings) do
    if type(entry) ~= "table" or type(entry.key) ~= "string" or entry.action == nil then
        report(("custom entry #%d needs a string `key` and an `action`"):format(i))
    else
        local normalized = normalizeKey(entry.key)
        if customKeys[normalized] then
            report("duplicate custom keybinding ignored: " .. entry.key)
        else
            customKeys[normalized] = true
            validCustom[#validCustom + 1] = entry
        end
    end
end

-- Custom entries replace defaults on the same key; defaults must be unique.
local finalBindings, seenDefaults = {}, {}
for _, entry in ipairs(bindings) do
    local normalized = normalizeKey(entry.key)
    if not customKeys[normalized] then
        if seenDefaults[normalized] then
            report(("duplicate default keybinding ignored: %s (%s)")
                :format(entry.key, (entry.options and entry.options.description) or "no description"))
        else
            seenDefaults[normalized] = true
            finalBindings[#finalBindings + 1] = entry
        end
    end
end
for _, entry in ipairs(validCustom) do
    finalBindings[#finalBindings + 1] = {
        key     = entry.key,
        action  = entry.action,
        options = entry.options or {},
    }
end

-- Register each binding in isolation so one bad entry cannot block the rest.
for _, entry in ipairs(finalBindings) do
    local bound, err = pcall(hl.bind, entry.key, entry.action, entry.options)
    if not bound then
        report(("could not bind %s: %s"):format(entry.key, tostring(err)))
    end
end

if #problems > 0 then
    hl.notification.create({
        text     = ("Keybinds: %d problem(s). Run `hyprctl rollinglog` for details."):format(#problems),
        duration = 8000,
        icon     = "warning",
    })
end
