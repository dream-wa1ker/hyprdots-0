return {
  {
    "stevearc/conform.nvim",
    opts = {
      default_format_opts = {
        formatting_options = { tabSize = 4, insertSpaces = true },
      },
      formatters_by_ft = {
        c = { "clang_format" },
        sh = { "shfmt" },
        python = { "black" },
        lua = {},
      },
      formatters = {
        shfmt = {
          append_args = { "-i", "4" },
        },
        clang_format = {
          prepend_args = {
            "--style={BasedOnStyle: InheritParentConfig, IndentWidth: 4, TabWidth: 4, UseTab: Never, ColumnLimit: 0}",
          },
        },
      },
    },
  },
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = { "clang-format", "shfmt", "black" },
    },
  },
}
