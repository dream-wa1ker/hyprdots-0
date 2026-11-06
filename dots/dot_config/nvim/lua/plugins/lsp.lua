return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      format = {
        formatting_options = { tabSize = 4, insertSpaces = true },
      },
      -- Register settings without starting servers. Enable on demand with :lsp enable <name>.
      setup = {
        ["*"] = function(server, opts)
          vim.lsp.config(server, opts)
          return true -- Skip LazyVim/Mason automatic activation.
        end,
      },
      servers = {
        clangd = { enabled = true },
        bashls = { enabled = true },
        pyright = { enabled = true },
        lua_ls = {
          enabled = true,
          settings = {
            Lua = {
              format = {
                defaultConfig = {
                  indent_style = "space",
                  indent_size = "4",
                },
              },
            },
          },
        },
      },
    },
  },
}
