-- ~/.config/hypr/hyprland/execs.lua
-- dream-wa1ker

local vars = require("hyprland.variables")

hl.on("hyprland.start", function ()

    hl.exec_cmd("noctalia")
    hl.exec_cmd("hyprctl setcursor " ..vars.cursorTheme.. " "..vars.cursorSize)
    -- Core components (authentication, lock screen, notification daemon)
    hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")
    hl.exec_cmd("dbus-update-activation-environment --all")
    hl.exec_cmd("sleep 1 && dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")

    hl.exec_cmd("mpris-proxy")
    hl.exec_cmd("mpd-mpris")

    -- KDE Connect
    hl.exec_cmd("kdeconnect-indicator")

end)
