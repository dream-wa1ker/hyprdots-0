return {
    {
        -- We use a dedicated, minimal transparency engine instead of fighting base16
        "xiyaowong/transparent.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            -- Force Neovim to fallback onto terminal ANSI color spaces 
            vim.opt.termguicolors = false 

            -- Load the default terminal palette interpreter
            vim.cmd("colorscheme default")

            -- Initialize the background stripper
            require("transparent").setup({
                extra_groups = {
                    "NormalFloat", -- Floating windows (like LSPs)
                    "NvimTreeNormal", -- File tree background if you use one
                    "NeoTreeNormal",
                    "SignColumn", -- Git gutter signs column
                    "LineNr", -- Line numbers column
                    "StatusLine", -- Statusline panels
                    "StatusLineNC",
                    "EndOfBuffer", -- Tildes (~) at empty lines
                },
            })
            
            -- Enforce it globally
            require("transparent").clear()
        end,
    },
}

