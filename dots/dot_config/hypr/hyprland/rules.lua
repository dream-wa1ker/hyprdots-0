-- ~/.config/hypr/hyprland/rules.lua
local vars = require("variables")
local boot = require("core.bootstrap")

----------------------
---- Window rules ----
----------------------

local window_rules = {
    -- Center all floating windows (skip xwayland — breaks popups/menus)
    { match = { float = true, xwayland = false }, center = true },

    ------------------------------------------------------------------
    -- Opaque apps: forces solid regardless of the universal transparency
    -- set in decoration.lua. Rebuilt against what's actually installed —
    -- video/image/screenshot content and shell UI look wrong blurred/see-
    -- through; everything else stays universally transparent as you asked.
    ------------------------------------------------------------------
    { match = { class = "mpv" },                tag = "+opaque_app" }, -- video playback
    { match = { class = "org.kde.okular" },      tag = "+opaque_app" }, -- document/image reader
    { match = { class = "swappy" },              tag = "+opaque_app" }, -- screenshot editor
    { match = { class = "org.quickshell" },      tag = "+opaque_app" }, -- caelestia shell surfaces
    { match = { tag = "opaque_app" },            opaque = true },

    ------------------------------------------------------------------
    -- Floating utility apps (sized/centered via variables.floatRules,
    -- applied at spawn time by fn.floatSpawnRule in keybinds.lua — these
    -- window_rule entries just catch the ones NOT spawned through a keybind,
    -- e.g. launched from a menu/rofi/fuzzel directly)
    ------------------------------------------------------------------

    -- GTK/portal file pickers and misc system dialogs (xdg-desktop-portal-gtk)
    {
        match = {
            title = "(Select|Open)( a)? (File|Folder)(s)?|File (Operation|Upload)( Progress)?|.* Properties|Save As",
        },
        tag = "+float",
    },

    { match = { tag = "float" }, float = true },

    ------------------------------------------------------------------
    -- Proportionally-sized floating utility windows (scale with monitor,
    -- unlike variables.floatRules which is fixed-pixel)
    ------------------------------------------------------------------
    { match = { class = "org.pulseaudio.pavucontrol" },   tag = "+float_60_70" },
    { match = { class = "dev.geopjr.Tuba" },              tag = "+float_70_80" },
    { match = { class = "nwg-look" },                     tag = "+float_50_60" },
    { match = { class = "blueman-manager" },              tag = "+float_60_70" },
    { match = { class = "org.kde.partitionmanager" },     tag = "+float_70_80" },

    {
        match  = { tag = "float_60_70" },
        float  = true,
        size   = "(monitor_w*0.6) (monitor_h*0.7)",
        center = true,
    },
    {
        match  = { tag = "float_70_80" },
        float  = true,
        size   = "(monitor_w*0.7) (monitor_h*0.8)",
        center = true,
    },
    {
        match  = { tag = "float_50_60" },
        float  = true,
        size   = "(monitor_w*0.5) (monitor_h*0.6)",
        center = true,
    },

    -- Xwayland empty-title/class popups (menus, tooltips) — don't dim/shadow/blur
    { match = { xwayland = true, title = "win[0-9]+" }, tag = "+xwl_popup" },
    {
        match = { xwayland = true, title = "", class = "", initial_title = "", initial_class = "" },
        tag   = "+xwl_popup",
    },
    {
        match     = { tag = "xwl_popup" },
        no_dim    = true,
        no_shadow = true,
        no_blur   = true,
        opaque    = true,
        rounding  = 10,
    },

    -- Communication -> special workspace (element-desktop is your matrix client)
    { match = { class = "dev.geopjr.Tuba|Element" },        workspace = "special:communication" },
    { match = { class = "org.kde.plasma-systemmonitor" },   workspace = "special:sysmon" },

    ------------------------------------------------------------------
    -- File pickers / system dialogs by window title (float + center,
    -- some with an explicit size)
    ------------------------------------------------------------------
    { match = { title = "^(Open File)(.*)$" },        center = true },
    { match = { title = "^(Open File)(.*)$" },        float = true },
    { match = { title = "^(Select a File)(.*)$" },    center = true },
    { match = { title = "^(Select a File)(.*)$" },    float = true },
    { match = { title = "^(Choose wallpaper)(.*)$" }, center = true },
    { match = { title = "^(Choose wallpaper)(.*)$" }, float = true },
    { match = { title = "^(Choose wallpaper)(.*)$" }, size = { "(monitor_w*0.60)", "(monitor_h*0.65)" } },
    { match = { title = "^(Open Folder)(.*)$" },      center = true },
    { match = { title = "^(Open Folder)(.*)$" },      float = true },
    { match = { title = "^(Save As)(.*)$" },          center = true },
    { match = { title = "^(Save As)(.*)$" },          float = true },
    { match = { title = "^(Library)(.*)$" },          center = true },
    { match = { title = "^(Library)(.*)$" },          float = true },
    { match = { title = "^(File Upload)(.*)$" },      center = true },
    { match = { title = "^(File Upload)(.*)$" },      float = true },
    { match = { title = "^(.*)(wants to save)$" },    center = true },
    { match = { title = "^(.*)(wants to save)$" },    float = true },
    { match = { title = "^(.*)(wants to open)$" },    center = true },
    { match = { title = "^(.*)(wants to open)$" },    float = true },

    ------------------------------------------------------------------
    -- Misc apps that should always float
    ------------------------------------------------------------------
    { match = { class = "^(blueberry\\.py)$" }, float = true }, -- Bluetooth manager
    { match = { class = "^(guifetch)$" },       float = true }, -- FlafyDev/guifetch

    -- pavucontrol: float, size, and center (both legacy and portal class names)
    { match = { class = "^(pavucontrol)$" },                float = true },
    { match = { class = "^(pavucontrol)$" },                size = { "(monitor_w*0.45)", "(monitor_h*0.45)" } },
    { match = { class = "^(pavucontrol)$" },                center = true },
    { match = { class = "^(org.pulseaudio.pavucontrol)$" }, float = true },
    { match = { class = "^(org.pulseaudio.pavucontrol)$" }, size = { "(monitor_w*0.45)", "(monitor_h*0.45)" } },
    { match = { class = "^(org.pulseaudio.pavucontrol)$" }, center = true },

    -- NetworkManager connection editor: float, size, and center
    { match = { class = "^(nm-connection-editor)$" }, float = true },
    { match = { class = "^(nm-connection-editor)$" }, size = { "(monitor_w*0.45)", "(monitor_h*0.45)" } },
    { match = { class = "^(nm-connection-editor)$" }, center = true },

    { match = { class = ".*plasmawindowed.*" },        float = true }, -- Plasma applets run standalone
    { match = { class = "kcm_.*" },                    float = true }, -- KDE System Settings modules
    { match = { class = ".*bluedevilwizard" },         float = true }, -- Bluetooth pairing wizard
    { match = { title = ".*Welcome" },                 float = true },
    { match = { title = "^(illogical-impulse Settings)$" }, float = true },
    { match = { title = ".*Shell conflicts.*" },       float = true },

    { match = { class = "org.freedesktop.impl.portal.desktop.kde" }, float = true },
    { match = { class = "org.freedesktop.impl.portal.desktop.kde" }, size = { "(monitor_w*0.60)", "(monitor_h*0.65)" } },

    { match = { class = "^(Zotero)$" }, float = true },
    { match = { class = "^(Zotero)$" }, size = { "(monitor_w*0.45)", "(monitor_h*0.45)" } },

    ------------------------------------------------------------------
    -- Move (offscreen / repositioned windows)
    ------------------------------------------------------------------
    -- kde-material-you-colors spawns a window when changing dark/light theme.
    -- This makes sure it never interferes visually — parked off-screen.
    { match = { class = "^(plasma-changeicons)$" }, float = true },
    { match = { class = "^(plasma-changeicons)$" }, no_initial_focus = true },
    { match = { class = "^(plasma-changeicons)$" }, move = { 999999, 999999 } },

    -- Dolphin's copy-progress dialog pops up centered by default; nudge it aside.
    { match = { title = "^(Copying — Dolphin)$" }, move = { 40, 80 } },

    ------------------------------------------------------------------
    -- Tiling
    ------------------------------------------------------------------
    { match = { class = "^dev\\.warp\\.Warp$" }, tile = true },

    ------------------------------------------------------------------
    -- Picture-in-Picture: float, pinned, fixed size/position, keep aspect
    ------------------------------------------------------------------
    { match = { title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$" }, float = true },
    { match = { title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$" }, keep_aspect_ratio = true },
    { match = { title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$" }, move = { "(monitor_w*0.73)", "(monitor_h*0.72)" } },
    { match = { title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$" }, size = { "(monitor_w*0.25)", "(monitor_h*0.25)" } },
    { match = { title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$" }, pin = true },

    ------------------------------------------------------------------
    -- Screen sharing indicator: float, pinned, docked at bottom-center
    ------------------------------------------------------------------
    { match = { title = ".*is sharing (a window|your screen).*" }, float = true },
    { match = { title = ".*is sharing (a window|your screen).*" }, pin = true },
    { match = { title = ".*is sharing (a window|your screen).*" }, move = { "(monitor_w*.5-window_w*.5)", "(monitor_h-window_h-12)" } },

    ------------------------------------------------------------------
    -- Tearing: force immediate presentation for latency-sensitive/
    -- frame-perfect content (games, .exe under wine/proton)
    ------------------------------------------------------------------
    { match = { title = ".*\\.exe" },         immediate = true },
    { match = { title = ".*minecraft.*" },    immediate = true },
    { match = { class = "^(steam_app).*" },   immediate = true },

    -- No shadow for tiled windows (only floating windows get shadows)
    { match = { float = 0 }, no_shadow = true },
}

boot.apply_all(hl.window_rule, window_rules, "rules.window")

-------------------------
---- Workspace rules ----
-------------------------

local workspace_rules = {
    -- Smart gaps: no gaps when a workspace/monitor has exactly one window
    { workspace = "w[tv1]s[false]", gaps_out = vars.singleWindowGapsOut },
    { workspace = "f[1]s[false]",   gaps_out = vars.singleWindowGapsOut },

    -- special:communication uses a scrolling layout with full-width columns —
    -- each app takes the entire monitor width; scrolling horizontally between
    -- them behaves like paging through full-screen apps rather than tiling
    -- side-by-side.
    {
        workspace = "special:communication",
        layout    = "scrolling",
        layout_opts = {
            column_width     = 1.0, -- 1.0 = full monitor width per column
            focus_fit_method = 1,   -- 1 = fit (scroll the focused column fully into view, not just centered)
            follow_focus     = true,
            direction        = "right",
        },
    },

    { workspace = "special:special", gaps_out = 30 },
}

boot.apply_all(hl.workspace_rule, workspace_rules, "rules.workspace")

---------------------
---- Layer rules ----
---------------------

local layer_rules = {
    ------------------------------------------------------------------
    -- Fade-only animations for transient/system-level surfaces
    ------------------------------------------------------------------
    { match = { namespace = "hyprpicker" },     animation = "fade" },
    { match = { namespace = "logout_dialog" },  animation = "fade" },
    { match = { namespace = "selection" },      animation = "fade" }, -- slurp
    { match = { namespace = "wayfreeze" },      animation = "fade" },
    { match = { namespace = "launcher" },       animation = "popin 80%", blur = true }, -- fuzzel/wofi

    ------------------------------------------------------------------
    -- Global xray, then per-namespace opt-outs of animation
    ------------------------------------------------------------------
    { match = { namespace = ".*" },        xray = true },
    { match = { namespace = "walker" },    no_anim = true },
    { match = { namespace = "selection" }, no_anim = true },
    { match = { namespace = "overview" },  no_anim = true },
    { match = { namespace = "anyrun" },    no_anim = true },
    { match = { namespace = "indicator.*" }, no_anim = true },
    { match = { namespace = "osk" },       no_anim = true },
    { match = { namespace = "hyprpicker" }, no_anim = true },

    { match = { namespace = "noanim" },         no_anim = true },
    { match = { namespace = "gtk-layer-shell" }, blur = true },
    { match = { namespace = "gtk-layer-shell" }, ignore_alpha = 0 },
    { match = { namespace = "launcher" },       blur = true },
    { match = { namespace = "launcher" },       ignore_alpha = 0.5 },
    { match = { namespace = "notifications" },  blur = true },
    { match = { namespace = "notifications" },  ignore_alpha = 0.69 },
    { match = { namespace = "logout_dialog" },  blur = true }, -- wlogout

    ------------------------------------------------------------------
    -- AGS shell surfaces (sidebars, bars, docks, overview, OSK, etc.)
    ------------------------------------------------------------------
    { match = { namespace = "sideleft.*" },  animation = "slide left" },
    { match = { namespace = "sideright.*" }, animation = "slide right" },
    { match = { namespace = "session[0-9]*" },   blur = true },
    { match = { namespace = "bar[0-9]*" },       blur = true },
    { match = { namespace = "bar[0-9]*" },       ignore_alpha = 0.6 },
    { match = { namespace = "barcorner.*" },     blur = true },
    { match = { namespace = "barcorner.*" },     ignore_alpha = 0.6 },
    { match = { namespace = "dock[0-9]*" },      blur = true },
    { match = { namespace = "dock[0-9]*" },      ignore_alpha = 0.6 },
    { match = { namespace = "indicator.*" },     blur = true },
    { match = { namespace = "indicator.*" },     ignore_alpha = 0.6 },
    { match = { namespace = "overview[0-9]*" },  blur = true },
    { match = { namespace = "overview[0-9]*" },  ignore_alpha = 0.6 },
    { match = { namespace = "cheatsheet[0-9]*" }, blur = true },
    { match = { namespace = "cheatsheet[0-9]*" }, ignore_alpha = 0.6 },
    { match = { namespace = "sideright[0-9]*" },  blur = true },
    { match = { namespace = "sideright[0-9]*" },  ignore_alpha = 0.6 },
    { match = { namespace = "sideleft[0-9]*" },   blur = true },
    { match = { namespace = "sideleft[0-9]*" },   ignore_alpha = 0.6 },
    { match = { namespace = "osk[0-9]*" },        blur = true },
    { match = { namespace = "osk[0-9]*" },        ignore_alpha = 0.6 },

    ------------------------------------------------------------------
    -- Quickshell: illogical-impulse namespaces
    ------------------------------------------------------------------
    { match = { namespace = "quickshell:.*" }, blur_popups = true },
    { match = { namespace = "quickshell:.*" }, blur = true },
    { match = { namespace = "quickshell:.*" }, ignore_alpha = 0.79 },

    { match = { namespace = "quickshell:bar" },               animation = "slide" },
    { match = { namespace = "quickshell:actionCenter" },      no_anim = true },
    { match = { namespace = "quickshell:cheatsheet" },        animation = "slide bottom" },
    { match = { namespace = "quickshell:dock" },              animation = "slide bottom" },
    { match = { namespace = "quickshell:screenCorners" },     animation = "popin 120%" },
    { match = { namespace = "quickshell:lockWindowPusher" },  no_anim = true },
    { match = { namespace = "quickshell:notificationPopup" }, animation = "fade" },
    { match = { namespace = "quickshell:overlay" },           no_anim = true },
    { match = { namespace = "quickshell:overlay" },           ignore_alpha = 1 },
    { match = { namespace = "quickshell:overview" },          no_anim = true },
    { match = { namespace = "quickshell:osk" },               animation = "slide bottom" },
    { match = { namespace = "quickshell:polkit" },            no_anim = true },
    { match = { namespace = "quickshell:popup" },             xray = false },       -- prevents odd tint on bar tooltips
    { match = { namespace = "quickshell:popup" },             ignore_alpha = 1 },   -- xray=false alone isn't enough; belt & suspenders
    { match = { namespace = "quickshell:mediaControls" },     ignore_alpha = 1 },   -- same tint fix as popups
    { match = { namespace = "quickshell:reloadPopup" },       animation = "slide" },
    { match = { namespace = "quickshell:regionSelector" },    no_anim = true },
    { match = { namespace = "quickshell:screenshot" },        no_anim = true },
    { match = { namespace = "quickshell:session" },           blur = true },
    { match = { namespace = "quickshell:session" },           no_anim = true },
    { match = { namespace = "quickshell:session" },           ignore_alpha = 0 },
    { match = { namespace = "quickshell:sidebarRight" },      animation = "slide right" },
    { match = { namespace = "quickshell:sidebarLeft" },       animation = "slide left" },
    { match = { namespace = "quickshell:verticalBar" },       animation = "slide" },
    { match = { namespace = "quickshell:osk" },               order = -1 },

    ------------------------------------------------------------------
    -- Quickshell: waffles namespaces
    ------------------------------------------------------------------
    { match = { namespace = "quickshell:wallpaperSelector" },    animation = "slide top" },
    { match = { namespace = "quickshell:wNotificationCenter" },  no_anim = true },
    { match = { namespace = "quickshell:wOnScreenDisplay" },     no_anim = true },
    { match = { namespace = "quickshell:wStartMenu" },           no_anim = true },
    { match = { namespace = "quickshell:wTaskView" },             ignore_alpha = 0 },
    { match = { namespace = "quickshell:wTaskView" },             no_anim = true },

    -- Launchers need to be FAST — no animation delay before first paint
    { match = { namespace = "gtk4-layer-shell" }, no_anim = true },
}

boot.apply_all(hl.layer_rule, layer_rules, "rules.layer")


