-- ~/.config/hypr/hyprland/execs.lua
-- dream-wa1ker

local vars = require("hyprland.variables")

hl.on("hyprland.start", function ()

    -- Shell-specific components
    if vars.shell ~= "noctalia" then
        -- Bar, wallpaper
        hl.exec_cmd("qs -c $qsConfig")
        hl.exec_cmd("$HOME/.config/hypr/custom/scripts/__restore_video_wallpaper.sh")

        -- Clipboard: history
        hl.exec_cmd("wl-paste --type text --watch bash -c 'cliphist store && qs -c $qsConfig ipc call cliphistService update'")
        hl.exec_cmd("wl-paste --type image --watch bash -c 'cliphist store && qs -c $qsConfig ipc call cliphistService update'")
    else
        hl.exec_cmd("noctalia")
    end
        

    -- Always-started services
    hl.exec_cmd("$HOME/.config/hypr/hyprland/scripts/start_geoclue_agent.sh")

    -- Core components (authentication, lock screen, notification daemon)
    hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("dbus-update-activation-environment --all")
    hl.exec_cmd("sleep 1 && dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")

    -- Audio
    hl.exec_cmd("easyeffects --hide-window --service-mode")

    -- Cursor and media
    hl.exec_cmd("hyprctl setcursor Bibata-Modern-Classic 14")
    hl.exec_cmd("mpris-proxy")
    hl.exec_cmd("mpd-mpris")

    -- KDE Connect
    hl.exec_cmd("kdeconnect-indicator")

end)
