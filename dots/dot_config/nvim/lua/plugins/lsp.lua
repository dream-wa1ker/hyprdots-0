return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      format = {
        formatting_options = { tabSize = 4, insertSpaces = true },
      },
      -- Start clangd and LuaLS normally; keep Bash and Python on demand.
      setup = {
        ["*"] = function(server, opts)
          if server == "bashls" or server == "pyright" then
            vim.lsp.config(server, opts)
            return true -- Skip automatic activation; use :lsp enable <name>.
          end
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
