-- define custom rules

return {
    -- define rules for the special workspace; out gap 20
    workspace = {
        {
            workspace = "special:special",
            -- Scrolling layout
            layout = "scrolling",
            layout_opts = {
                direction = "right",
            },
            gaps_out = 20,
        },

    },
    window = {
        {
            match = {
                workspace = "special:special",
            },
            scrolling_width = 0.5,
        },
    },
}
