return {
  {
    "RRethy/base16-nvim",
    lazy = true,
  },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function()
        require("lazy").load({ plugins = { "base16-nvim" } })
        require("matugen").setup()
      end,
    },
  },
}
