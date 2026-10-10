
-- ~/.config/hypr/hyprland/keybinds/shared.lua
-- Shell-independent Hyprland keybindings

local vars = require("hyprland.variables")
local fn   = require("hyprland.functions")

------------------------------------------------------------------
-- Workspaces 1-10 / groups
------------------------------------------------------------------

for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0

    hl.bind(vars.kbGoToWs .. " + " .. key,
        fn.wsaction("focus", "", i),
        { description = "Workspaces: Focus Workspace " .. i })

    hl.bind(vars.kbMoveWinToWs .. " + " .. key,
        fn.wsaction("move", "", i),
        { description = "Workspaces: Move Window to Workspace " .. i })

    hl.bind(vars.kbGoToWsGroup .. " + " .. key,
        fn.wsaction("focus", "group", i),
        { description = "Workspaces: Focus Group Workspace " .. i })

    hl.bind(vars.kbMoveWinToWsGroup .. " + " .. key,
        fn.wsaction("move", "group", i),
        { description = "Workspaces: Move Window to Group Workspace " .. i })
end

-- Workspace -1/+1
hl.bind("SUPER + mouse_down",
    hl.dsp.focus({ workspace = "-1" }),
    { description = "Workspaces: Focus Previous Workspace" })

hl.bind("SUPER + mouse_up",
    hl.dsp.focus({ workspace = "+1" }),
    { description = "Workspaces: Focus Next Workspace" })

hl.bind(vars.kbPrevWs,
    hl.dsp.focus({ workspace = "-1" }),
    { repeating = true, description = "Workspaces: Focus Previous Workspace" })

hl.bind(vars.kbNextWs,
    hl.dsp.focus({ workspace = "+1" }),
    { repeating = true, description = "Workspaces: Focus Next Workspace" })

hl.bind("SUPER + Page_Up",
    hl.dsp.focus({ workspace = "-10" }),
    { repeating = true, description = "Workspaces: Focus Previous Workspace Group" })

hl.bind("SUPER + Page_down",
    hl.dsp.focus({ workspace = "+10" }),
    { repeating = true, description = "Workspaces: Focus Next Workspace Group" })

-- Workspace group -1/+1
hl.bind("CTRL + SUPER + mouse_down",
    hl.dsp.focus({ workspace = "-10" }),
    { description = "Workspaces: Focus Previous Workspace Group" })

hl.bind("CTRL + SUPER + mouse_up",
    hl.dsp.focus({ workspace = "+10" }),
    { description = "Workspaces: Focus Next Workspace Group" })

-- Move window to workspace -1/+1
hl.bind("SUPER + ALT + Page_Up",
    hl.dsp.window.move({ workspace = "-1" }),
    { repeating = true, description = "Workspaces: Move Window to Previous Workspace" })

hl.bind("SUPER + ALT + Page_Down",
    hl.dsp.window.move({ workspace = "+1" }),
    { repeating = true, description = "Workspaces: Move Window to Next Workspace" })

hl.bind("SUPER + ALT + mouse_down",
    hl.dsp.window.move({ workspace = "-1" }),
    { description = "Workspaces: Move Window to Previous Workspace" })

hl.bind("SUPER + ALT + mouse_up",
    hl.dsp.window.move({ workspace = "+1" }),
    { description = "Workspaces: Move Window to Next Workspace" })

hl.bind("CTRL + SUPER + SHIFT + right",
    hl.dsp.window.move({ workspace = "+10" }),
    { repeating = true, description = "Workspaces: Move Window to Next Workspace Group" })

hl.bind("CTRL + SUPER + SHIFT + left",
    hl.dsp.window.move({ workspace = "-10" }),
    { repeating = true, description = "Workspaces: Move Window to Previous Workspace Group" })

-- Move to/from special workspace
hl.bind("CTRL + SUPER + up",
    hl.dsp.window.move({ workspace = "special:special" }),
    { description = "Workspaces: Move Window to Special Workspace" })

hl.bind("CTRL + SUPER + down",
    hl.dsp.window.move({ workspace = "e+0" }),
    { description = "Workspaces: Move Window Out of Special Workspace" })

------------------------------------------------------------------
-- Window groups
------------------------------------------------------------------

hl.bind(vars.kbWindowGroupCycleNext,
    hl.dsp.window.cycle_next(),
    { repeating = true, description = "Group: Focus Next Window in Group" })

hl.bind(vars.kbWindowGroupCyclePrev,
    hl.dsp.window.cycle_next({ next = false }),
    { repeating = true, description = "Group: Focus Previous Window in Group" })

hl.bind("CTRL + Tab",
    hl.dsp.group.next(),
    { repeating = true, description = "Group: Switch to Next Group Window" })

hl.bind("CTRL + SHIFT + Tab",
    hl.dsp.group.prev(),
    { repeating = true, description = "Group: Switch to Previous Group Window" })

hl.bind(vars.kbToggleGroup,
    hl.dsp.group.toggle(),
    { description = "Group: Toggle Window Grouping" })

hl.bind(vars.kbUngroup,
    hl.dsp.window.move({ out_of_group = true }),
    { description = "Group: Move Window Out of Group" })

hl.bind("SUPER + SHIFT + Comma",
    hl.dsp.group.lock_active(),
    { description = "Group: Lock Active Group" })

------------------------------------------------------------------
-- Focus / move windows by direction
------------------------------------------------------------------

hl.bind("SUPER + left",
    hl.dsp.focus({ direction = "left" }),
    { description = "Focus: Focus Left Window" })

hl.bind("SUPER + right",
    hl.dsp.focus({ direction = "right" }),
    { description = "Focus: Focus Right Window" })

hl.bind("SUPER + up",
    hl.dsp.focus({ direction = "up" }),
    { description = "Focus: Focus Up Window" })

hl.bind("SUPER + down",
    hl.dsp.focus({ direction = "down" }),
    { description = "Focus: Focus Down Window" })

hl.bind("SUPER + SHIFT + left",
    hl.dsp.window.move({ direction = "left" }),
    { description = "Window: Move Window Left" })

hl.bind("SUPER + SHIFT + right",
    hl.dsp.window.move({ direction = "right" }),
    { description = "Window: Move Window Right" })

hl.bind("SUPER + SHIFT + up",
    hl.dsp.window.move({ direction = "up" }),
    { description = "Window: Move Window Up" })

hl.bind("SUPER + SHIFT + down",
    hl.dsp.window.move({ direction = "down" }),
    { description = "Window: Move Window Down" })

------------------------------------------------------------------
-- Window resize
------------------------------------------------------------------

hl.bind("SUPER + Minus",
    fn.resize_active(-10, 0),
    { repeating = true, description = "Window: Shrink Window Width" })

hl.bind("SUPER + Equal",
    fn.resize_active(10, 0),
    { repeating = true, description = "Window: Expand Window Width" })

hl.bind("SUPER + SHIFT + Minus",
    fn.resize_active(0, -10),
    { repeating = true, description = "Window: Shrink Window Height" })

hl.bind("SUPER + SHIFT + Equal",
    fn.resize_active(0, 10),
    { repeating = true, description = "Window: Expand Window Height" })

hl.bind("SUPER + ALT + left",
    fn.resize_active(-10, 0),
    { repeating = true, description = "Window: Shrink Window Width" })

hl.bind("SUPER + ALT + right",
    fn.resize_active(10, 0),
    { repeating = true, description = "Window: Expand Window Width" })

hl.bind("SUPER + ALT + up",
    fn.resize_active(0, -10),
    { repeating = true, description = "Window: Shrink Window Height" })

hl.bind("SUPER + ALT + down",
    fn.resize_active(0, 10),
    { repeating = true, description = "Window: Expand Window Height" })

-- Move/resize with mouse
hl.bind("SUPER + mouse:272",
    hl.dsp.window.drag(),
    { mouse = true, description = "Mouse: Move Window" })

hl.bind("SUPER + mouse:273",
    hl.dsp.window.resize(),
    { mouse = true, description = "Mouse: Resize Window" })

-- Other window functions
hl.bind("SUPER + Backslash",
    hl.dsp.window.center(),
    { description = "Window: Center Window" })

hl.bind("CTRL + Backslash",
    fn.resize_screen(55, 70),
    { description = "Window: Resize to 55x70 Percent of Screen" })

hl.bind(vars.kbWindowPip,
    fn.toggle_pip,
    { description = "Window: Toggle Picture-in-Picture Mode" })

hl.bind(vars.kbPinWindow,
    hl.dsp.window.pin(),
    { description = "Window: Pin/Unpin Window" })

hl.bind(vars.kbWindowPseudo,
    hl.dsp.window.pseudo(),
    { description = "Window: Toggle Pseudotiled" })

hl.bind(vars.kbWindowFullscreen,
    hl.dsp.window.fullscreen({ mode = "fullscreen" }),
    { description = "Window: Toggle Fullscreen" })

hl.bind(vars.kbWindowBorderedFullscreen,
    hl.dsp.window.fullscreen({ mode = "maximized" }),
    { description = "Window: Toggle Maximized" })

hl.bind(vars.kbToggleWindowFloating,
    fn.toggle_floating,
    { description = "Window: Toggle Floating State and Auto-Size" })

hl.bind(vars.kbCloseWindow,
    hl.dsp.window.close(),
    { description = "Window: Close Active Window" })

------------------------------------------------------------------
-- Layouts
------------------------------------------------------------------

hl.bind(vars.kbToggleWsLayout,
    fn.cycle_all_layouts,
    { description = "Layout: Cycle Workspace Layout (All Types)" })

hl.bind(vars.kbToggleWsScrollLayout,
    fn.toggle_scroll_layout,
    { description = "Layout: Toggle Dwindle / Scrolling Layout" })

------------------------------------------------------------------
-- Special workspaces
------------------------------------------------------------------

hl.bind(vars.kbSpecialWs,
    hl.dsp.workspace.toggle_special("special"),
    { description = "Workspaces: Toggle Special Workspace" })

hl.bind(vars.kbSysmonWs,
    hl.dsp.workspace.toggle_special("sysmon"),
    { description = "Workspaces: Toggle Sysmon Workspace" })

hl.bind(vars.kbCommunicationWs,
    hl.dsp.workspace.toggle_special("communication"),
    { description = "Workspaces: Toggle Communication Workspace" })

------------------------------------------------------------------
-- Applications
------------------------------------------------------------------

-- Launch tiled applications
hl.bind(vars.kbTerminal,
    hl.dsp.exec_cmd(vars.terminal),
    { description = "Applications: Launch Terminal" })

hl.bind(vars.kbBrowser,
    hl.dsp.exec_cmd(vars.browser),
    { description = "Applications: Launch Web Browser" })

hl.bind(vars.kbEditor,
    hl.dsp.exec_cmd(vars.editor),
    { description = "Applications: Launch Text Editor" })

hl.bind(vars.kbFileExplorer,
    hl.dsp.exec_cmd(vars.fileExplorer),
    { description = "Applications: Launch File Manager" })

hl.bind("CTRL + ALT + V",
    hl.dsp.exec_cmd(vars.audioSettings),
    { description = "Applications: Launch Volume Mixer" })

-- Launch floating applications
hl.bind("SHIFT + " .. vars.kbTerminal,
    hl.dsp.exec_cmd(vars.terminal, fn.floatSpawnRule(vars.terminal, { float = true })),
    { description = "Applications: Launch Terminal (Floating)" })

hl.bind("SHIFT + " .. vars.kbBrowser,
    hl.dsp.exec_cmd(vars.browser, fn.floatSpawnRule(vars.browser, { float = true })),
    { description = "Applications: Launch Web Browser (Floating)" })

hl.bind("SHIFT + " .. vars.kbEditor,
    hl.dsp.exec_cmd(vars.editor, fn.floatSpawnRule(vars.editor, { float = true })),
    { description = "Applications: Launch Text Editor (Floating)" })

hl.bind("SHIFT + " .. vars.kbFileExplorer,
    hl.dsp.exec_cmd(vars.fileExplorer, fn.floatSpawnRule(vars.fileExplorer, { float = true })),
    { description = "Applications: Launch File Manager (Floating)" })

hl.bind("CTRL + " .. vars.kbTerminal,
    hl.dsp.exec_cmd(vars.terminal, fn.floatSpawnRule(vars.terminal, { pseudo = true })),
    { description = "Applications: Launch Terminal (Pseudotiled)" })

------------------------------------------------------------------
-- Utilities
------------------------------------------------------------------

hl.bind("SUPER + P",
    hl.dsp.exec_cmd("hyprpicker -a"),
    { description = "Utilities: Launch Color Picker" })

hl.bind("CTRL + Print",
    hl.dsp.exec_cmd(
        'grim -o "$(hyprctl activeworkspace -j | jq -r \'.monitor\')" - | wl-copy'
    ),
    { locked = true, description = "Utilities: Copy Monitor Screenshot to Clipboard" })

hl.bind("Print",
    hl.dsp.exec_cmd(
        'mkdir -p "$(xdg-user-dir PICTURES)/Screenshots" && grim -o "$(hyprctl activeworkspace -j | jq -r \'.monitor\')" "$(xdg-user-dir PICTURES)/Screenshots/Screenshot_$(date \'+%Y-%m-%d_%H.%M.%S\').png"'
    ),
    { description = "Utilities: Save Monitor Screenshot" })

------------------------------------------------------------------
-- Audio
------------------------------------------------------------------

hl.bind("XF86AudioMicMute",
    hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
    { locked = true, description = "Media: Toggle Microphone Mute" })

hl.bind("XF86AudioMute",
    hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
    { locked = true, description = "Media: Toggle Audio Mute" })

hl.bind("SUPER + SHIFT + M",
    hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
    { locked = true, description = "Media: Toggle Audio Mute" })

hl.bind(
    "XF86AudioRaiseVolume",
    hl.dsp.exec_cmd(
        "wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; wpctl set-volume -l " ..
        (vars.volumeMax / 100) .. " @DEFAULT_AUDIO_SINK@ " .. vars.volumeStep .. "%+"
    ),
    { locked = true, repeating = true, description = "Media: Increase Audio Volume" }
)

hl.bind(
    "XF86AudioLowerVolume",
    hl.dsp.exec_cmd(
        "wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; wpctl set-volume @DEFAULT_AUDIO_SINK@ " ..
        vars.volumeStep .. "%-"
    ),
    { locked = true, repeating = true, description = "Media: Decrease Audio Volume" }
)

------------------------------------------------------------------
-- Display brightness
------------------------------------------------------------------

hl.bind("XF86MonBrightnessUp",
    hl.dsp.exec_cmd("brightnessctl s 5%+"),
    { locked = true, description = "System: Increase Display Brightness" })

hl.bind("XF86MonBrightnessDown",
    hl.dsp.exec_cmd("brightnessctl s 5%-"),
    { locked = true, description = "System: Decrease Display Brightness" })

------------------------------------------------------------------
-- Keyboard backlight
------------------------------------------------------------------

hl.bind("SUPER + XF86MonBrightnessUp",
    hl.dsp.exec_cmd("brightnessctl -d platform::kbd_backlight set +1"),
    { description = "System: Increase Keyboard Backlight" })

hl.bind("SUPER + XF86MonBrightnessDown",
    hl.dsp.exec_cmd("brightnessctl -d platform::kbd_backlight set 1-"),
    { description = "System: Decrease Keyboard Backlight" })

------------------------------------------------------------------
-- Sleep
------------------------------------------------------------------

hl.bind("SUPER + SHIFT + L",
    hl.dsp.exec_cmd(vars.sleepGestureCmd),
    { locked = true, description = "Session: Put System to Sleep" })

------------------------------------------------------------------
-- Media playback
------------------------------------------------------------------

hl.bind("CTRL + SUPER + Space",
    hl.dsp.exec_cmd("playerctl play-pause"),
    { locked = true, description = "Media: Toggle Play/Pause" })

hl.bind("XF86AudioPlay",
    hl.dsp.exec_cmd("playerctl play-pause"),
    { locked = true, description = "Media: Toggle Play/Pause" })

hl.bind("XF86AudioPause",
    hl.dsp.exec_cmd("playerctl play-pause"),
    { locked = true, description = "Media: Toggle Play/Pause" })

local nextTrack = 'playerctl next || playerctl position `bc <<< "100 * $(playerctl metadata mpris:length) / 1000000 / 100"`'

hl.bind("CTRL + SUPER + Equal",
    hl.dsp.exec_cmd(nextTrack),
    { locked = true, description = "Media: Next Track" })

hl.bind("XF86AudioNext",
    hl.dsp.exec_cmd(nextTrack),
    { locked = true, description = "Media: Next Track" })

hl.bind("CTRL + SUPER + Minus",
    hl.dsp.exec_cmd("playerctl previous"),
    { locked = true, description = "Media: Previous Track" })

hl.bind("XF86AudioPrev",
    hl.dsp.exec_cmd("playerctl previous"),
    { locked = true, description = "Media: Previous Track" })

hl.bind("XF86AudioStop",
    hl.dsp.exec_cmd("playerctl stop"),
    { locked = true, description = "Media: Stop Playback" })

hl.bind("SUPER + SHIFT + N",
    hl.dsp.exec_cmd(nextTrack),
    { description = "Media: Next Track" })

hl.bind("SUPER + SHIFT + P",
    hl.dsp.exec_cmd("playerctl previous"),
    { description = "Media: Previous Track" })

hl.bind("SUPER + SHIFT + B",
    hl.dsp.exec_cmd("playerctl play-pause"),
    { description = "Media: Toggle Play/Pause" })

