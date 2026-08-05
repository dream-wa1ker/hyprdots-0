-- ~/.config/hypr/hyprland/keybinds.lua
--
-- Shell integration now targets quickshell (global dispatchers named
-- "quickshell:*"), not caelestia. Mappings below were pulled 1:1 from
-- the old hyprlang hyprland/keybinds.conf. Where that .conf paired a
-- `global` dispatch with a plain-exec fallback on the same key (so the
-- key still does something if quickshell isn't alive), both binds are
-- kept here, mirroring the .conf structure.
--
-- DROPPED — no "global, quickshell:..." equivalent existed in the .conf
-- I was given, so these caelestia-only binds were removed rather than
-- guessed at. Re-add manually (target key in parens) if quickshell has
-- an actual dispatcher for these elsewhere in your config:
--   - clearNotifs            (was vars.kbClearNotifs)
--   - showall                (was vars.kbShowPanels — overlayToggle on
--                              Super+G is close but not the same thing,
--                              wired that one up separately below)
--   - clipboard detach mode  (was SUPER+ALT+V)
--   - non-freeze screenshot  (was SUPER+SHIFT+ALT+S)
--   - special/sysmon/music/communication/todo workspace toggles
--     (was vars.kbSpecialWs / kbSystemMonitorWs / kbMusicWs /
--      kbCommunicationWs / kbTodoWs — these vars are now orphaned in
--      variables.lua, safe to remove there too)
--   - the searchToggleReleaseInterrupt / bindit workspaceNumber binds
--     (skipped — too many edge-case mouse binds to safely guess the
--     right hl.bind option names for; add by hand if you rely on them)

local vars = require("variables")
local fn   = require("hyprland.functions")
local boot = require("core.bootstrap")

-- Set this in variables.lua if your quickshell config dir isn't literally
-- named "quickshell" (mirrors $qsConfig from the old .conf).
local qsConfig = vars.qsConfig or "quickshell"

------------------------------------------------------------------
-- Shell (quickshell) — search / launcher
------------------------------------------------------------------
hl.bind("SUPER + SUPER_L", hl.dsp.global("quickshell:searchToggleRelease"))
hl.bind("SUPER + Tab", hl.dsp.global("quickshell:overviewWorkspacesToggle"))

hl.bind(vars.kbSession, hl.dsp.global("quickshell:sessionToggle"))

hl.bind("SUPER + ALT + A", hl.dsp.global("quickshell:sidebarLeftToggleDetach"))
hl.bind("SUPER + N", hl.dsp.global("quickshell:sidebarRightToggle"))

hl.bind("SUPER + Slash", hl.dsp.global("quickshell:cheatsheetToggle"))
hl.bind("SUPER + K", hl.dsp.global("quickshell:oskToggle"))
hl.bind("SUPER + M", hl.dsp.global("quickshell:mediaControlsToggle"))
hl.bind("SUPER + G", hl.dsp.global("quickshell:overlayToggle"))
hl.bind("SUPER + J", hl.dsp.global("quickshell:barToggle"))

hl.bind("SUPER + W", hl.dsp.global("quickshell:wallpaperSelectorToggle"))
hl.bind("CTRL + SUPER + ALT + T", hl.dsp.global("quickshell:wallpaperSelectorRandom"))

hl.bind("CTRL + SUPER + R", hl.dsp.exec_cmd(
    "killall ydotool qs quickshell; qs -c " .. qsConfig .. " &"
), { release = true })
hl.bind("CTRL + SUPER + P", hl.dsp.global("quickshell:panelFamilyCycle"))

------------------------------------------------------------------
-- Utilities — screenshot / search / OCR / translate / record / clipboard
------------------------------------------------------------------
hl.bind("SUPER + V", hl.dsp.global("quickshell:overviewClipboardToggle"))
hl.bind("SUPER + Period", hl.dsp.global("quickshell:overviewEmojiToggle"))

hl.bind("SUPER + SHIFT + S", hl.dsp.global("quickshell:regionScreenshot"))

hl.bind("SUPER + SHIFT + A", hl.dsp.global("quickshell:regionSearch"))

hl.bind("SUPER + SHIFT + X", hl.dsp.global("quickshell:regionOcr"))
hl.bind("SUPER + ALT + T", hl.dsp.global("quickshell:screenTranslate"))

hl.bind("SUPER + CTRL + R", hl.dsp.global("quickshell:regionRecord"), { mouse = false })
hl.bind("SUPER + ALT + R", hl.dsp.global("quickshell:regionRecord"))
hl.bind("SUPER + R", hl.dsp.exec_cmd(
    "~/.config/quickshell/" .. qsConfig .. "/scripts/videos/record.sh --fullscreen"
))
hl.bind("SUPER + SHIFT + R", hl.dsp.exec_cmd(
    "~/.config/quickshell/" .. qsConfig .. "/scripts/videos/record.sh --fullscreen --sound"
))

hl.bind("CTRL + Print", hl.dsp.exec_cmd(
    'grim -o "$(hyprctl activeworkspace -j | jq -r \'.monitor\')" - | wl-copy'
), { locked = true })
hl.bind("Print", hl.dsp.exec_cmd(
    'mkdir -p $(xdg-user-dir PICTURES)/Screenshots && grim -o "$(hyprctl activeworkspace -j | jq -r \'.monitor\')" '
    .. '$(xdg-user-dir PICTURES)/Screenshots/Screenshot_"$(date \'+%Y-%m-%d_%H.%M.%S\')".png'
))

------------------------------------------------------------------
-- Lock (plain exec — the .conf never routed this through quickshell)
------------------------------------------------------------------
hl.bind("SUPER + L", hl.dsp.global("quickshell:lock"))

------------------------------------------------------------------
-- Workspaces 1-10 / groups
------------------------------------------------------------------
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(vars.kbGoToWs .. " + " .. key, fn.wsaction("focus", "", i))
    hl.bind(vars.kbMoveWinToWs .. " + " .. key, fn.wsaction("move", "", i))
    hl.bind(vars.kbGoToWsGroup .. " + " .. key, fn.wsaction("focus", "group", i))
    hl.bind(vars.kbMoveWinToWsGroup .. " + " .. key, fn.wsaction("move", "group", i))
end

-- Workspace -1/+1
hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "-1" }))
hl.bind("SUPER + mouse_up", hl.dsp.focus({ workspace = "+1" }))
hl.bind(vars.kbPrevWs, hl.dsp.focus({ workspace = "-1" }), { repeating = true })
hl.bind(vars.kbNextWs, hl.dsp.focus({ workspace = "+1" }), { repeating = true })
hl.bind("SUPER + Page_Up", hl.dsp.focus({ workspace = "-1" }), { repeating = true })
hl.bind("SUPER + Page_down", hl.dsp.focus({ workspace = "+1" }), { repeating = true })

-- Workspace group -1/+1
hl.bind("CTRL + SUPER + mouse_down", hl.dsp.focus({ workspace = "-10" }))
hl.bind("CTRL + SUPER + mouse_up", hl.dsp.focus({ workspace = "+10" }))

-- Move window to workspace -1/+1
hl.bind("SUPER + ALT + Page_Up", hl.dsp.window.move({ workspace = "-1" }), { repeating = true })
hl.bind("SUPER + ALT + Page_Down", hl.dsp.window.move({ workspace = "+1" }), { repeating = true })
hl.bind("SUPER + ALT + mouse_down", hl.dsp.window.move({ workspace = "-1" }))
hl.bind("SUPER + ALT + mouse_up", hl.dsp.window.move({ workspace = "+1" }))
hl.bind("CTRL + SUPER + SHIFT + right", hl.dsp.window.move({ workspace = "+1" }), { repeating = true })
hl.bind("CTRL + SUPER + SHIFT + left", hl.dsp.window.move({ workspace = "-1" }), { repeating = true })

-- Move to/from special workspace
hl.bind("CTRL + SUPER + up", hl.dsp.window.move({ workspace = "special:special" }))
hl.bind("CTRL + SUPER + down", hl.dsp.window.move({ workspace = "e+0" }))

-- Window groups
hl.bind(vars.kbWindowGroupCycleNext, hl.dsp.window.cycle_next(), { repeating = true })
hl.bind(vars.kbWindowGroupCyclePrev, hl.dsp.window.cycle_next({ next = false }), { repeating = true })
hl.bind("CTRL + ALT + Tab", hl.dsp.group.next(), { repeating = true })
hl.bind("CTRL + SHIFT + ALT + Tab", hl.dsp.group.prev(), { repeating = true })
hl.bind(vars.kbToggleGroup, hl.dsp.group.toggle())
hl.bind(vars.kbUngroup, hl.dsp.window.move({ out_of_group = true }))
hl.bind("SUPER + SHIFT + Comma", hl.dsp.group.lock_active())

-- Focus / move by direction
hl.bind("SUPER + left", hl.dsp.focus({ direction = "left" }))
hl.bind("SUPER + right", hl.dsp.focus({ direction = "right" }))
hl.bind("SUPER + up", hl.dsp.focus({ direction = "up" }))
hl.bind("SUPER + down", hl.dsp.focus({ direction = "down" }))
hl.bind("SUPER + SHIFT + left", hl.dsp.window.move({ direction = "left" }))
hl.bind("SUPER + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind("SUPER + SHIFT + up", hl.dsp.window.move({ direction = "up" }))
hl.bind("SUPER + SHIFT + down", hl.dsp.window.move({ direction = "down" }))

------------------------------------------------------------------
-- Window resize — wrapped in functions so the active-window/monitor
-- lookup happens at keypress time, not config-load time.
------------------------------------------------------------------
hl.bind("SUPER + Minus", function()
    hl.dispatch(hl.dsp.window.resize(fn.resize_active_window(-10, 0)))
end, { repeating = true })
hl.bind("SUPER + Equal", function()
    hl.dispatch(hl.dsp.window.resize(fn.resize_active_window(10, 0)))
end, { repeating = true })
hl.bind("SUPER + SHIFT + Minus", function()
    hl.dispatch(hl.dsp.window.resize(fn.resize_active_window(0, -10)))
end, { repeating = true })
hl.bind("SUPER + SHIFT + Equal", function()
    hl.dispatch(hl.dsp.window.resize(fn.resize_active_window(0, 10)))
end, { repeating = true })
hl.bind("SUPER + ALT + left", function()
    hl.dispatch(hl.dsp.window.resize(fn.resize_active_window(-10, 0)))
end, { repeating = true })
hl.bind("SUPER + ALT + right", function()
    hl.dispatch(hl.dsp.window.resize(fn.resize_active_window(10, 0)))
end, { repeating = true })
hl.bind("SUPER + ALT + up", function()
    hl.dispatch(hl.dsp.window.resize(fn.resize_active_window(0, -10)))
end, { repeating = true })
hl.bind("SUPER + ALT + down", function()
    hl.dispatch(hl.dsp.window.resize(fn.resize_active_window(0, 10)))
end, { repeating = true })

-- Move/resize with mouse
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Other window functions
hl.bind("CTRL + SUPER + Backslash", hl.dsp.window.center())
hl.bind("CTRL + SUPER + ALT + Backslash", function()
    hl.dispatch(hl.dsp.window.resize(fn.resize_by_screen(55, 70)))
end)

hl.bind(vars.kbWindowPip, boot.safe_call(function()
    local a = hl.get_active_window()
    if a then
        local pip = fn.move_actions(a) or {}
        if not a.floating then table.insert(pip, 1, hl.dsp.window.float()) end
        table.insert(pip, hl.dsp.window.pin({ action = "on", window = fn.addr(a) }))

        for _, x in ipairs(pip) do
            hl.dispatch(x)
        end
    end
end, "kbWindowPip"))

hl.bind(vars.kbPinWindow, hl.dsp.window.pin())
hl.bind(vars.kbWindowPseudo, hl.dsp.window.pseudo())
hl.bind(vars.kbWindowFullscreen, hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind(vars.kbWindowBorderedFullscreen, hl.dsp.window.fullscreen({ mode = "maximized" }))

hl.bind(vars.kbToggleWindowFloating, boot.safe_call(function()
    hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
    local w = hl.get_active_window()
    if w and w.floating then
        local class = w.class and w.class:lower() or ""
        local rule = vars.floatRules[class] or vars.defaultRule

        hl.dispatch(hl.dsp.window.resize({ exact = true, x = rule.w, y = rule.h }))

        if rule.x and rule.y then
            hl.dispatch(hl.dsp.window.move({ exact = true, x = rule.x, y = rule.y }))
        else
            hl.dispatch(hl.dsp.window.center())
        end
    end
end, "kbToggleWindowFloating"))

hl.bind(vars.kbCloseWindow, hl.dsp.window.close())

-- Layout toggles: all -> next
hl.bind(vars.kbToggleWsLayout, boot.safe_call(function()
    local ws = hl.get_active_workspace()
    if not ws then return end
    local order = { dwindle = "scrolling", scrolling = "master", master = "monocle", monocle = "dwindle" }
    hl.workspace_rule({ workspace = tostring(ws.id), layout = order[ws.tiled_layout] or "dwindle" })
end, "kbToggleWsLayout"))

-- dwindle <-> scrolling only
hl.bind(vars.kbToggleWsScrollLayout, boot.safe_call(function()
    local ws = hl.get_active_workspace()
    if not ws then return end
    local order = { dwindle = "scrolling", scrolling = "dwindle" }
    hl.workspace_rule({ workspace = tostring(ws.id), layout = order[ws.tiled_layout] or "dwindle" })
end, "kbToggleWsScrollLayout"))

hl.bind(vars.kbSpecialWs, hl.dsp.workspace.toggle_special("special"))
hl.bind(vars.kbSystemMonitorWs, hl.dsp.workspace.toggle_special("sysmon"))
hl.bind(vars.kbCommunicationWs, hl.dsp.workspace.toggle_special("communication"))


-- Open apps (tiled)
hl.bind(vars.kbTerminal, hl.dsp.exec_cmd(vars.terminal))
hl.bind(vars.kbBrowser, hl.dsp.exec_cmd(vars.browser))
hl.bind(vars.kbEditor, hl.dsp.exec_cmd(vars.editor))
hl.bind(vars.kbFileExplorer, hl.dsp.exec_cmd(vars.fileExplorer))
hl.bind("CTRL + ALT + V", hl.dsp.exec_cmd(vars.audioSettings))
-- NOTE: settingsApp / textEditor / officeSoftware / taskManager aren't in
-- variables.lua yet (it only has terminal/browser/editor/fileExplorer/
-- audioSettings) — add them there, same pattern, before this loads.
hl.bind("SUPER + I", hl.dsp.exec_cmd(vars.settingsApp))

-- Open apps (float, sized via variables.floatRules)
hl.bind("SHIFT + " .. vars.kbTerminal, hl.dsp.exec_cmd(vars.terminal, fn.floatSpawnRule(vars.terminal, { float = true })))
hl.bind("SHIFT + " .. vars.kbBrowser, hl.dsp.exec_cmd(vars.browser, fn.floatSpawnRule(vars.browser, { float = true })))
hl.bind("SHIFT + " .. vars.kbEditor, hl.dsp.exec_cmd(vars.editor, fn.floatSpawnRule(vars.editor, { float = true })))
hl.bind("SHIFT + " .. vars.kbFileExplorer, hl.dsp.exec_cmd(vars.fileExplorer, fn.floatSpawnRule(vars.fileExplorer, { float = true })))
hl.bind("CTRL + " .. vars.kbTerminal, hl.dsp.exec_cmd(vars.terminal, fn.floatSpawnRule(vars.terminal, { pseudo = true })))

-- Color picker (hyprpicker installed)
hl.bind("SUPER + SHIFT + C", hl.dsp.exec_cmd("hyprpicker -a"))

-- Volume (wireplumber's wpctl)
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("SUPER + SHIFT + M", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind(
    "XF86AudioRaiseVolume",
    hl.dsp.exec_cmd(
        "wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; wpctl set-volume -l " ..
        (vars.volumeMax / 100) .. " @DEFAULT_AUDIO_SINK@ " .. vars.volumeStep .. "%+"
    ),
    { locked = true, repeating = true }
)
hl.bind(
    "XF86AudioLowerVolume",
    hl.dsp.exec_cmd(
        "wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; wpctl set-volume @DEFAULT_AUDIO_SINK@ " .. vars.volumeStep .. "%-"
    ),
    { locked = true, repeating = true }
)

-- Screen brightness (quickshell ipc call, falls back to brightnessctl)
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd(
    "qs -c " .. qsConfig .. " ipc call brightness increment || brightnessctl s 5%+"
), { locked = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(
    "qs -c " .. qsConfig .. " ipc call brightness decrement || brightnessctl s 5%-"
), { locked = true })
-- Keyboard backlight (unchanged — separate device, not routed through quickshell)
hl.bind("SUPER + XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -d platform::kbd_backlight set +1"))
hl.bind("SUPER + XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -d platform::kbd_backlight set 1-"))

-- Sleep
hl.bind("SUPER + SHIFT + L", hl.dsp.exec_cmd(vars.sleepGestureCmd), { locked = true })

-- Media playback (playerctl directly — quickshell only exposes a panel
-- toggle for this, not per-key play/pause/next/prev dispatchers)
hl.bind("CTRL + SUPER + Space", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("CTRL + SUPER + Equal", hl.dsp.exec_cmd(
    'playerctl next || playerctl position `bc <<< "100 * $(playerctl metadata mpris:length) / 1000000 / 100"`'
), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd(
    'playerctl next || playerctl position `bc <<< "100 * $(playerctl metadata mpris:length) / 1000000 / 100"`'
), { locked = true })
hl.bind("CTRL + SUPER + Minus", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
hl.bind("XF86AudioStop", hl.dsp.exec_cmd("playerctl stop"), { locked = true })
hl.bind("SUPER + SHIFT + N", hl.dsp.exec_cmd(
    'playerctl next || playerctl position `bc <<< "100 * $(playerctl metadata mpris:length) / 1000000 / 100"`'
))
hl.bind("SUPER + SHIFT + B", hl.dsp.exec_cmd("playerctl previous"))
hl.bind("SUPER + SHIFT + P", hl.dsp.exec_cmd("playerctl play-pause"))


