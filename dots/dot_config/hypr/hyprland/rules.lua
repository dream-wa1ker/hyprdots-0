-- ~/.config/hypr/hyprland/rules.lua
-- dream-wa1ker
local vars = require("hyprland.variables")
local boot = require("core.bootstrap")
local apps = require("hyprland.lib.apps")

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
    { match = { class = "org.quickshell" },      tag = "+opaque_app" },  
    { match = { tag = "opaque_app" },            opaque = true },

    -- GTK/portal file pickers and misc system dialogs (xdg-desktop-portal-gtk)
    {
        match = {
            title = "(Select|Open)( a)? (File|Folder)(s)?|File (Operation|Upload)( Progress)?|.* Properties|Save As",
        },
        tag = "+float",
    },

    { match = { tag = "float" }, float = true },

    -- Expanded from variables.apps at these positions to preserve precedence.
    { utility = "tuba" },
    { utility = "appearance" },
    { utility = "bluetooth" },
    { utility = "partitionManager" },

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
    {
        match = { title = "^(Open File)(.*)$" },
        center = true,
        float = true,
    },
    {
        match = { title = "^(Select a File)(.*)$" },
        center = true,
        float = true,
    },
    {
        match = { title = "^(Choose wallpaper)(.*)$" },
        center = true,
        float = true,
        size = { "(monitor_w*0.60)", "(monitor_h*0.65)" },
    },
    {
        match = { title = "^(Open Folder)(.*)$" },
        center = true,
        float = true,
    },
    {
        match = { title = "^(Save As)(.*)$" },
        center = true,
        float = true,
    },
    {
        match = { title = "^(Library)(.*)$" },
        center = true,
        float = true,
    },
    {
        match = { title = "^(File Upload)(.*)$" },
        center = true,
        float = true,
    },
    {
        match = { title = "^(.*)(wants to save)$" },
        center = true,
        float = true,
    },
    {
        match = { title = "^(.*)(wants to open)$" },
        center = true,
        float = true,
    },

    ------------------------------------------------------------------
    -- Misc apps that should always float
    ------------------------------------------------------------------
    { match = { class = "^(blueberry\\.py)$" }, float = true }, -- Bluetooth manager
    { match = { class = "^(guifetch)$" },       float = true }, -- FlafyDev/guifetch

    { utility = "audioMixer" },
    { utility = "networkEditor" },

    { match = { class = ".*plasmawindowed.*" },        float = true }, -- Plasma applets run standalone
    { match = { class = "kcm_.*" },                    float = true }, -- KDE System Settings modules
    { match = { class = ".*bluedevilwizard" },         float = true }, -- Bluetooth pairing wizard
    { match = { title = ".*Welcome" },                 float = true },
    { match = { title = ".*Shell conflicts.*" },       float = true },

    { utility = "kdePortal" },
    { utility = "zotero" },

    ------------------------------------------------------------------
    -- Move (offscreen / repositioned windows)
    ------------------------------------------------------------------
    -- kde-material-you-colors spawns a window when changing dark/light theme.
    -- This makes sure it never interferes visually — parked off-screen.
    {
        match = { class = "^(plasma-changeicons)$" },
        float = true,
        no_initial_focus = true,
        move = { 999999, 999999 },
    },

    -- Dolphin's copy-progress dialog pops up centered by default; nudge it aside.
    { match = { title = "^(Copying — Dolphin)$" }, move = { 40, 80 } },

    ------------------------------------------------------------------
    -- Tiling
    ------------------------------------------------------------------
    { match = { class = "^dev\\.warp\\.Warp$" }, tile = true },

    ------------------------------------------------------------------
    -- Picture-in-Picture: float, pinned, fixed size/position, keep aspect
    ------------------------------------------------------------------
    {
        match = { title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$" },
        float = true,
        keep_aspect_ratio = true,
        move = { "(monitor_w*0.73)", "(monitor_h*0.72)" },
        size = { "(monitor_w*0.25)", "(monitor_h*0.25)" },
        pin = true,
    },

    ------------------------------------------------------------------
    -- Screen sharing indicator: float, pinned, docked at bottom-center
    ------------------------------------------------------------------
    {
        match = { title = ".*is sharing (a window|your screen).*" },
        float = true,
        pin = true,
        move = { "(monitor_w*.5-window_w*.5)", "(monitor_h-window_h-12)" },
    },

    ------------------------------------------------------------------
    -- Tearing: force immediate presentation for latency-sensitive/
    -- frame-perfect content (games, .exe under wine/proton)
    ------------------------------------------------------------------
    { match = { title = ".*\\.exe" },         immediate = true },
    { match = { title = ".*minecraft.*" },    immediate = true },
    { match = { class = "^(steam_app).*" },   immediate = true },

    -- No shadow for tiled windows (only floating windows get shadows)
    { match = { float = false }, no_shadow = true },
    { utility = "noctalia" },
}

local expanded, handled = {}, {}
local function add_utility(id)
    local rule = apps.floating_rule(id)
    if rule then expanded[#expanded + 1] = rule end
end

for _, rule in ipairs(window_rules) do
    if rule.utility then
        handled[rule.utility] = true
        add_utility(rule.utility)
    else expanded[#expanded + 1] = rule end
end

-- New custom utility specifications are deterministic and precede custom/rules.lua.
for _, id in ipairs(apps.ids()) do
    if not handled[id] then add_utility(id) end
end

boot.apply_all(hl.window_rule, expanded, "rules.window")

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

    { workspace = "special:special", gaps_out = 10 },
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


    -- Launchers need to be FAST — no animation delay before first paint
    { match = { namespace = "gtk4-layer-shell" }, no_anim = true },
}

-- add this new layer rule : noctalia specific; don't bunch apply.
hl.layer_rule({
  name = "noctalia",
  match = {
    namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$",
  },
  no_anim = true,
  ignore_alpha = 0.5,
  blur = true,
  blur_popups = true,
})

boot.apply_all(hl.layer_rule, layer_rules, "rules.layer")


