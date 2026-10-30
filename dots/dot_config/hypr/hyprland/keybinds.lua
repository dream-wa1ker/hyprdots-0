-- Core binding behaviors. Each record below has an id, description, and action/builder.
-- Its key is configured under the SAME NAME in hyprland/variables.lua's keybinds table.
-- For personal changes, edit custom/variables.lua (keys) and custom/keybinds.lua (behavior).
-- Add a matching setting and binding record to define a new shortcut; see custom/keybinds.lua.
-- Registration, validation, and fallbacks are implemented in lib/keybinds.lua.
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
        id = "launcher", description = "Toggle Launcher / Search",
        build_action = function() return noctalia("panel-toggle launcher") end,
        options = {
            release = true,
        },
    },
    {
        id = "keybindCheatsheet", description = "View Keybindings Cheatsheet",
        build_action = function() return hl.dsp.exec_cmd('bash "$HOME/.dotfiles/scripts/keybinds.sh"') end,
    },
    {
        id = "clipboard", description = "Toggle Clipboard History",
        build_action = function() return noctalia("panel-toggle clipboard") end,
    },
    {
        id = "emojiSearch", description = "Toggle Emoji Searcher",
        build_action = function() return noctalia('panel-toggle launcher "/emo "') end,
    },
    {
        id = "shellPanelSelector", description = "Toggle Shell Panel Selector",
        build_action = function() return noctalia('panel-toggle launcher "/"') end,
    },
    {
        id = "windowSwitcher", description = "Toggle Window Switcher",
        build_action = function() return noctalia("window-switcher hold") end,
    },
    {
        id = "dashboard", description = "Toggle Main Dashboard",
        build_action = function() return noctalia("panel-toggle control-center") end,
    },
    {
        id = "notifications", description = "Toggle Notifications Panel",
        build_action = function() return noctalia("panel-toggle control-center notifications") end,
    },
    {
        id = "mediaPanel", description = "Toggle Media Panel",
        build_action = function() return noctalia("panel-toggle control-center media") end,
    },
    {
        id = "barToggle", description = "Toggle the Visibility of Default Bar",
        build_action = function() return noctalia("bar-toggle default") end,
    },
    {
        id = "sessionPanel", description = "Toggle Session Panel",
        build_action = function() return noctalia("panel-toggle session") end,
    },
    {
        id = "lockScreen", description = "Activate Lock Screen",
        build_action = function() return noctalia("session lock") end,
    },
    {
        id = "reloadNoctalia", description = "Reload Noctalia Configuration",
        build_action = function() return noctalia("config-reload") end,
        options = {
            release = true,
        },
    },
    {
        id = "suspend", description = "Session: Lock and Suspend",
        build_action = function() return noctalia("session lock-and-suspend") end,
        options = {
            locked = true,
        },
    },
    {
        id = "archUpdater", description = "View Pending Arch System Updates",
        build_action = function() return noctalia("panel-toggle yuuto/arch-updater:panel") end,
    },
    {
        id = "pomodoro", description = "Toggle Focus Pomodoro",
        build_action = function() return noctalia("panel-toggle thepunkoff/pomodoro:panel") end,
    },
    {
        id = "notes", description = "Open Notes Side Bar",
        build_action = function() return noctalia("panel-toggle noctalia/notes:panel") end,
    },
    {
        id = "liveAnnotation", description = "Activate Live Screen Annotation",
        build_action = function() return noctalia("annotate") end,
    },
    {
        id = "ocrRegion", description = "OCR Selector for a Region",
        build_action = function() return noctalia("plugin fel/ocr:ocr all ocr-region") end,
    },
    {
        id = "frozenAnnotation", description = "Activate Frozen Screen Annotation",
        build_action = function() return noctalia("screenshot-annotate") end,
    },
    {
        id = "ocrFullscreen", description = "OCR Selector for Fullscreen",
        build_action = function() return noctalia("plugin fel/ocr:ocr all ocr-screen") end,
    },
    {
        id = "recordFullscreen", description = "Recording: Start Fullscreen (Audio)",
        build_action = function() return hl.dsp.exec_cmd(recorder .. "record-fullscreen") end,
    },
    {
        id = "recordRegion", description = "Recording: Select Region (Audio)",
        build_action = function() return hl.dsp.exec_cmd(recorder .. "select-region") end,
    },
    {
        id = "stopRecording", description = "Recording: Stop",
        build_action = function() return hl.dsp.exec_cmd(recorder .. "stop") end,
    },
    {
        id = "screenshotRegion", description = "Screenshot: Region",
        build_action = function() return noctalia("screenshot-region") end,
    },
    {
        id = "screenshotClipboard", description = "Copy Monitor Screenshot to Clipboard",
        build_action = function() return hl.dsp.exec_cmd('grim -o "$(hyprctl activeworkspace -j | jq -r \'.monitor\')" - | wl-copy && notify-send -u low "Screenshot" "Monitor screenshot copied to clipboard"') end,
        options = {
            locked = true,
        },
    },
    {
        id = "screenshotSave", description = "Save Monitor Screenshot",
        build_action = function() return hl.dsp.exec_cmd('mkdir -p "$(xdg-user-dir PICTURES)/Screenshots" && grim -o "$(hyprctl activeworkspace -j | jq -r \'.monitor\')" "$(xdg-user-dir PICTURES)/Screenshots/Screenshot_$(date \'+%Y-%m-%d_%H.%M.%S\').png" && notify-send -u low "Screenshot" "Monitor screenshot saved to Pictures/Screenshots"') end,
    },
    {
        id = "noctaliaProfileSwitcher", description = "Switch Desktop Profile",
        build_action = function() return hl.dsp.exec_cmd('bash ~/.dotfiles/scripts/profile-switch') end,
    },
    {
        id = "wallpaperSelector", description = "Toggle Wallpaper Selector",
        build_action = function() return noctalia("panel-toggle wallpaper") end,
    },
    {
        id = "randomWallpaper", description = "Set Random Wallpaper",
        build_action = function() return noctalia("wallpaper-random") end,
    },
    {
        id = "noctaliaSettings", description = "Launch Noctalia Settings",
        build_action = function() return noctalia("settings-toggle") end,
    },

    -- Workspaces
    {
        id = "previousWorkspaceMouse", description = "Focus Previous Workspace",
        build_action = function() return hl.dsp.focus({ workspace = "-1" }) end,
    },
    {
        id = "nextWorkspaceMouse", description = "Focus Next Workspace",
        build_action = function() return hl.dsp.focus({ workspace = "+1" }) end,
    },
    {
        id = "previousWorkspace", description = "Focus Previous Workspace",
        build_action = function() return hl.dsp.focus({ workspace = "-1" }) end,
        options = {
            repeating = true,
        },
    },
    {
        id = "nextWorkspace", description = "Focus Next Workspace",
        build_action = function() return hl.dsp.focus({ workspace = "+1" }) end,
        options = {
            repeating = true,
        },
    },
    {
        id = "moveWindowPreviousWorkspace", description = "Move Window to Previous Workspace",
        build_action = function() return hl.dsp.window.move({ workspace = "-1" }) end,
        options = {
            repeating = true,
        },
    },
    {
        id = "moveWindowNextWorkspace", description = "Move Window to Next Workspace",
        build_action = function() return hl.dsp.window.move({ workspace = "+1" }) end,
        options = {
            repeating = true,
        },
    },
    {
        id = "moveWindowPreviousWorkspaceMouse", description = "Move Window to Previous Workspace",
        build_action = function() return hl.dsp.window.move({ workspace = "-1" }) end,
    },
    {
        id = "moveWindowNextWorkspaceMouse", description = "Move Window to Next Workspace",
        build_action = function() return hl.dsp.window.move({ workspace = "+1" }) end,
    },
    {
        id = "previousWorkspaceGroup", description = "Focus Previous Workspace Group",
        build_action = function() return hl.dsp.focus({ workspace = "-10" }) end,
        options = {
            repeating = true,
        },
    },
    {
        id = "nextWorkspaceGroup", description = "Focus Next Workspace Group",
        build_action = function() return hl.dsp.focus({ workspace = "+10" }) end,
        options = {
            repeating = true,
        },
    },
    {
        id = "previousWorkspaceGroupMouse", description = "Focus Previous Workspace Group",
        build_action = function() return hl.dsp.focus({ workspace = "-10" }) end,
    },
    {
        id = "nextWorkspaceGroupMouse", description = "Focus Next Workspace Group",
        build_action = function() return hl.dsp.focus({ workspace = "+10" }) end,
    },
    {
        id = "moveWindowNextWorkspaceGroup", description = "Move Window to Next Workspace Group",
        build_action = function() return hl.dsp.window.move({ workspace = "+10" }) end,
        options = {
            repeating = true,
        },
    },
    {
        id = "moveWindowPreviousWorkspaceGroup", description = "Move Window to Previous Workspace Group",
        build_action = function() return hl.dsp.window.move({ workspace = "-10" }) end,
        options = {
            repeating = true,
        },
    },
    {
        id = "specialWorkspace", description = "Toggle Special Workspace",
        build_action = function() return hl.dsp.workspace.toggle_special("special") end,
    },
    {
        id = "sysmonWorkspace", description = "Toggle Sysmon Workspace",
        build_action = function() return hl.dsp.workspace.toggle_special("sysmon") end,
    },
    {
        id = "communicationWorkspace", description = "Toggle Communication Workspace",
        build_action = function() return hl.dsp.workspace.toggle_special("communication") end,
    },
    {
        id = "moveWindowToSpecialWorkspace", description = "Move Window to Special Workspace",
        build_action = function() return hl.dsp.window.move({ workspace = "special:special" }) end,
    },
    {
        id = "moveWindowOutOfSpecialWorkspace", description = "Move Window Out of Special Workspace",
        build_action = function() return hl.dsp.window.move({ workspace = "e+0" }) end,
    },

    -- Windows
    {
        id = "toggleGroup", description = "Toggle Window Grouping",
        build_action = function() return hl.dsp.group.toggle() end,
    },
    {
        id = "ungroupWindow", description = "Move Window Out of Group",
        build_action = function() return hl.dsp.window.move({ out_of_group = true }) end,
    },
    {
        id = "lockActiveGroup", description = "Lock Active Group",
        build_action = function() return hl.dsp.group.lock() end,
    },
    {
        id = "nextWindowInGroup", description = "Focus Next Window in Group",
        build_action = function() return hl.dsp.window.cycle_next() end,
        options = {
            repeating = true,
        },
    },
    {
        id = "previousWindowInGroup", description = "Focus Previous Window in Group",
        build_action = function() return hl.dsp.window.cycle_next({ next = false }) end,
        options = {
            repeating = true,
        },
    },
    {
        id = "nextGroupWindow", description = "Switch to Next Group Window",
        build_action = function() return hl.dsp.group.next() end,
        options = {
            repeating = true,
        },
    },
    {
        id = "previousGroupWindow", description = "Switch to Previous Group Window",
        build_action = function() return hl.dsp.group.prev() end,
        options = {
            repeating = true,
        },
    },
    {
        id = "focusLeft", description = "Focus Left Window",
        build_action = function() return hl.dsp.focus({ direction = "left" }) end,
    },
    {
        id = "focusRight", description = "Focus Right Window",
        build_action = function() return hl.dsp.focus({ direction = "right" }) end,
    },
    {
        id = "focusUp", description = "Focus Up Window",
        build_action = function() return hl.dsp.focus({ direction = "up" }) end,
    },
    {
        id = "focusDown", description = "Focus Down Window",
        build_action = function() return hl.dsp.focus({ direction = "down" }) end,
    },
    {
        id = "moveLeft", description = "Move Window Left",
        build_action = function() return hl.dsp.window.move({ direction = "left" }) end,
    },
    {
        id = "moveRight", description = "Move Window Right",
        build_action = function() return hl.dsp.window.move({ direction = "right" }) end,
    },
    {
        id = "moveUp", description = "Move Window Up",
        build_action = function() return hl.dsp.window.move({ direction = "up" }) end,
    },
    {
        id = "moveDown", description = "Move Window Down",
        build_action = function() return hl.dsp.window.move({ direction = "down" }) end,
    },
    {
        id = "shrinkWidth", description = "Shrink Window Width",
        build_action = function() return fn.resize_active(-10, 0) end,
        options = {
            repeating = true,
        },
    },
    {
        id = "expandWidth", description = "Expand Window Width",
        build_action = function() return fn.resize_active(10, 0) end,
        options = {
            repeating = true,
        },
    },
    {
        id = "shrinkHeight", description = "Shrink Window Height",
        build_action = function() return fn.resize_active(0, -10) end,
        options = {
            repeating = true,
        },
    },
    {
        id = "expandHeight", description = "Expand Window Height",
        build_action = function() return fn.resize_active(0, 10) end,
        options = {
            repeating = true,
        },
    },
    {
        id = "shrinkWidthAlt", description = "Shrink Window Width",
        build_action = function() return fn.resize_active(-10, 0) end,
        options = {
            repeating = true,
        },
    },
    {
        id = "expandWidthAlt", description = "Expand Window Width",
        build_action = function() return fn.resize_active(10, 0) end,
        options = {
            repeating = true,
        },
    },
    {
        id = "shrinkHeightAlt", description = "Shrink Window Height",
        build_action = function() return fn.resize_active(0, -10) end,
        options = {
            repeating = true,
        },
    },
    {
        id = "expandHeightAlt", description = "Expand Window Height",
        build_action = function() return fn.resize_active(0, 10) end,
        options = {
            repeating = true,
        },
    },
    {
        id = "dragWindow", description = "Move Window Using Mouse",
        build_action = function() return hl.dsp.window.drag() end,
        options = {
            mouse = true,
        },
    },
    {
        id = "resizeWindowMouse", description = "Resize Window Using Mouse",
        build_action = function() return hl.dsp.window.resize() end,
        options = {
            mouse = true,
        },
    },
    {
        id = "centerWindow", description = "Move Window to Screen Center",
        build_action = function() return hl.dsp.window.center() end,
    },
    {
        id = "resizeWindowToScreen", description = "Resize Window to 55x70 Percent of Screen",
        build_action = function() return fn.resize_screen(55, 70) end,
    },
    {
        id = "pictureInPicture", description = "Toggle Picture-in-Picture Mode",
        build_action = function() return fn.toggle_pip end,
    },
    {
        id = "pinWindow", description = "Pin/Unpin Window",
        build_action = function() return hl.dsp.window.pin() end,
    },
    {
        id = "pseudotileWindow", description = "Toggle Pseudotiled Mode",
        build_action = function() return hl.dsp.window.pseudo() end,
    },
    {
        id = "fullscreenWindow", description = "Toggle Fullscreen Mode",
        build_action = function() return hl.dsp.window.fullscreen({ mode = "fullscreen" }) end,
    },
    {
        id = "maximizedWindow", description = "Toggle Maximized Mode",
        build_action = function() return hl.dsp.window.fullscreen({ mode = "maximized" }) end,
    },
    {
        id = "toggleFloating", description = "Toggle Floating Mode",
        build_action = function() return fn.toggle_floating end,
    },
    {
        id = "closeWindow", description = "Close Active Window",
        build_action = function() return hl.dsp.window.close() end,
    },
    {
        id = "cycleWorkspaceLayout", description = "Cycle Workspace Layout (All Types)",
        build_action = function() return fn.cycle_all_layouts end,
    },
    {
        id = "toggleScrollLayout", description = "Toggle between Dwindle and Scrolling Layout",
        build_action = function() return fn.toggle_scroll_layout end,
    },

    -- Applications
    {
        id = "terminal", description = "Launch Default Terminal",
        build_action = function() return apps.launch("terminal") end,
    },
    {
        id = "browser", description = "Launch Default Web Browser",
        build_action = function() return apps.launch("browser") end,
    },
    {
        id = "editor", description = "Launch Default Text Editor",
        build_action = function() return apps.launch("editor") end,
    },
    {
        id = "fileExplorer", description = "Launch Default File Manager",
        build_action = function() return apps.launch("fileManager") end,
    },
    {
        id = "audioMixer", description = "Launch Volume Mixer",
        build_action = function() return apps.launch("audioMixer") end,
    },
    {
        id = "floatingTerminal", description = "Launch Terminal in (Floating)",
        build_action = function() return apps.launch("terminal", { floating = true }) end,
    },
    {
        id = "floatingBrowser", description = "Launch Web Browser in (Floating)",
        build_action = function() return apps.launch("browser", { floating = true }) end,
    },
    {
        id = "floatingEditor", description = "Launch Text Editor in (Floating)",
        build_action = function() return apps.launch("editor", { floating = true }) end,
    },
    {
        id = "floatingFileExplorer", description = "Launch File Manager in (Floating)",
        build_action = function() return apps.launch("fileManager", { floating = true }) end,
    },
    {
        id = "pseudotiledTerminal", description = "Launch Terminal in (Pseudotiled)",
        build_action = function() return apps.launch("terminal", { pseudo = true }) end,
    },
    {
        id = "colorPicker", description = "Launch Color Picker",
        build_action = function() return apps.launch("colorPicker") end,
    },

    -- Media
    {
        id = "microphoneMute", description = "Toggle Microphone Mute",
        build_action = function() return hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle") end,
        options = {
            locked = true,
        },
    },
    {
        id = "audioMute", description = "Toggle Audio Mute",
        build_action = function() return hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle") end,
        options = {
            locked = true,
        },
    },
    {
        id = "audioMuteAlt", description = "Toggle Audio Mute",
        build_action = function() return hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle") end,
        options = {
            locked = true,
        },
    },
    {
        id = "volumeUp", description = "Increase Audio Volume",
        build_action = function() return hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; wpctl set-volume -l " .. (vars.volumeMax / 100) .. " @DEFAULT_AUDIO_SINK@ " .. vars.volumeStep .. "%+") end,
        options = {
            locked = true,
            repeating = true,
        },
    },
    {
        id = "volumeDown", description = "Decrease Audio Volume",
        build_action = function() return hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; wpctl set-volume @DEFAULT_AUDIO_SINK@ " .. vars.volumeStep .. "%-") end,
        options = {
            locked = true,
            repeating = true,
        },
    },
    {
        id = "brightnessUp", description = "Increase Display Brightness",
        build_action = function() return hl.dsp.exec_cmd("brightnessctl s 5%+") end,
        options = {
            locked = true,
        },
    },
    {
        id = "brightnessDown", description = "Decrease Display Brightness",
        build_action = function() return hl.dsp.exec_cmd("brightnessctl s 5%-") end,
        options = {
            locked = true,
        },
    },
    {
        id = "keyboardBacklightUp", description = "Increase Keyboard Backlight",
        build_action = function() return hl.dsp.exec_cmd("brightnessctl -d platform::kbd_backlight set +1") end,
    },
    {
        id = "keyboardBacklightDown", description = "Decrease Keyboard Backlight",
        build_action = function() return hl.dsp.exec_cmd("brightnessctl -d platform::kbd_backlight set 1-") end,
    },
    {
        id = "mediaPlay", description = "Toggle Play/Pause",
        build_action = function() return hl.dsp.exec_cmd("playerctl play-pause") end,
        options = {
            locked = true,
        },
    },
    {
        id = "mediaPause", description = "Toggle Play/Pause",
        build_action = function() return hl.dsp.exec_cmd("playerctl play-pause") end,
        options = {
            locked = true,
        },
    },
    {
        id = "mediaPlayAlt", description = "Toggle Play/Pause",
        build_action = function() return hl.dsp.exec_cmd("playerctl play-pause") end,
    },
    {
        id = "mediaNext", description = "Play Next Track",
        build_action = function() return hl.dsp.exec_cmd(nextTrack) end,
        options = {
            locked = true,
        },
    },
    {
        id = "mediaNextAlt", description = "Play Next Track",
        build_action = function() return hl.dsp.exec_cmd(nextTrack) end,
        options = {
            locked = true,
        },
    },
    {
        id = "mediaNextAlt2", description = "Play Next Track",
        build_action = function() return hl.dsp.exec_cmd(nextTrack) end,
    },
    {
        id = "mediaPrevious", description = "Play Previous Track",
        build_action = function() return hl.dsp.exec_cmd("playerctl previous") end,
        options = {
            locked = true,
        },
    },
    {
        id = "mediaPreviousAlt", description = "Play Previous Track",
        build_action = function() return hl.dsp.exec_cmd("playerctl previous") end,
        options = {
            locked = true,
        },
    },
    {
        id = "mediaPreviousAlt2", description = "Play Previous Track",
        build_action = function() return hl.dsp.exec_cmd("playerctl previous") end,
    },
    {
        id = "mediaStop", description = "Stop Playback",
        build_action = function() return hl.dsp.exec_cmd("playerctl stop") end,
        options = {
            locked = true,
        },
    },

    -- Placement
    {
        id = "geometryMode", description = "Enter Window Placement Mode",
        build_action = function() return hl.dsp.submap("geometry") end,
    },
    {
        id = "scrollHorizontal", description = "Scrolling Layout: Horizontal",
        action = function() fn.set_scroll_direction("right") end,
    },
    {
        id = "scrollVertical", description = "Scrolling Layout: Vertical",
        action = function() fn.set_scroll_direction("down") end,
    },
}

local function numbered_bindings()
    local entries = {}
    local families = {
        {"workspace.focus", "goToWorkspacePrefix", "focus", "", "Focus Workspace "},
        {"workspace.move", "moveWindowToWorkspacePrefix", "move", "", "Workspaces: Move Window to Workspace "},
        {"workspace.groupFocus", "goToWorkspaceGroupPrefix", "focus", "group", "Focus Workspace Group "},
        {"workspace.groupMove", "moveWindowToWorkspaceGroupPrefix", "move", "group", "Move Window to Workspace Group "},
    }
    for i = 1, 10 do
        for _, family in ipairs(families) do
            local id, prefix, verb, range, description = table.unpack(family)
            local index = i
            entries[#entries + 1] = {
                id = id .. "." .. index, parent = prefix,
                key = registry.workspace_key(vars.keybinds[prefix], index % 10),
                fallback_key = registry.workspace_key(registry.default_key(prefix), index % 10),
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
        {"geometryLeft", "left"}, {"geometryRight", "right"},
        {"geometryTop", "top"}, {"geometryBottom", "bottom"},
        {"geometryTopLeft", "top_left"}, {"geometryTopRight", "top_right"},
        {"geometryBottomLeft", "bottom_left"}, {"geometryBottomRight", "bottom_right"},
        {"geometryCenter", "center"}, {"geometryFill", "fill"}, {"geometryRestore", "restore"},
    }
    for _, pair in ipairs(presets) do
        local id, preset = pair[1], pair[2]
        entries[#entries + 1] = {
            id = id, submap = "geometry", description = "Window Placement: " .. preset,
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
local result = registry.register_catalog(bindings, function() return require("custom.keybinds") end)

hl.on("config.unload", function()
    if hl.get_current_submap() == "geometry" then hl.dispatch(hl.dsp.submap("reset")) end
end)

return result
