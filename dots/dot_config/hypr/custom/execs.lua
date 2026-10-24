-- ~/.config/hypr/custom/execs.lua
-- dream-wa1ker
--
-- PURPOSE   Programs that start with your session.
-- RETURNS   { startup = { "command", ... }, events = { { event = "...", callback = fn } } }
-- LOADED    After hyprland/execs.lua. Commands run when Hyprland STARTS, not on
--           `hyprctl reload`; log out and in (or run the command by hand) to test.
-- SECURITY  Everything listed here runs with your privileges at every login, which is
--           exactly what malware uses for persistence. Review this list now and then, and
--           start network-facing programs (KDE Connect, file sharing) only when needed.

return {
    startup = {
        -- Runs the active profile's post-apply.sh. Its colours are applied in Lua by
        -- custom/colors.lua; this hook only runs the profile's own checks.
        'bash "$HOME/.dotfiles/scripts/profile-init"',
        -- "nm-applet --indicator",
        -- "blueman-applet",
    },

    events = {
        -- A Lua callback instead of a command:
        -- { event = "hyprland.start", callback = function() hl.exec_cmd("notify-send 'Session started'") end },
    },
}
