return {
    {
        -- This tells lazy.nvim we are writing a pure configuration block 
        -- without pulling or cloning anything from the internet.
        dir = vim.fn.stdpath("config"),
        name = "native-transparent-nord",
        lazy = false,
        priority = 1000,
        config = function()
            -- 1. Strip all solid background highlight groups to let the terminal show through
            local function apply_transparency()
                local groups = {
                    "Normal", "NormalFloat", "NormalNC", "SignColumn", 
                    "LineNr", "CursorLineNr", "FoldColumn", "Window",
                    "StatusLine", "StatusLineNC", "VertSplit", "WinSeparator",
                    "Pmenu", "PmenuSel", "EndOfBuffer", "TabLine", "TabLineFill"
                }
                for _, group in ipairs(groups) do
                    vim.api.nvim_set_hl(0, group, { bg = "none", ctermbg = "none" })
                end
            end

            -- 2. Build a native event listener to keep transparency active
            vim.api.nvim_create_autocmd("ColorScheme", {
                pattern = "*",
                callback = apply_transparency,
            })

            -- 3. Set standard Nord variables natively supported by Neovim's fallback core
            vim.g.nord_disable_background = true
            vim.g.nord_italic = true

            -- 4. Load the built-in system theme
            -- If 'nord' throws an error, it falls back gracefully to 'default' using terminal ANSI
            pcall(vim.cmd, "colorscheme nord")

            -- 5. Execute transparency instantly
            apply_transparency()
        end,
    },
}

