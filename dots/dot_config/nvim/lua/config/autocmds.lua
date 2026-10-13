-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")


local function load_template(buf, template_path)
  local full_path = vim.fn.stdpath("config") .. "/templates/" .. template_path
  if vim.fn.filereadable(full_path) == 0 then return end

  local lines = vim.fn.readfile(full_path)
  local cursor_pos = nil

  for i, line in ipairs(lines) do
    lines[i] = line:gsub("//FILENAME//", vim.fn.expand("%:t"))
                   :gsub("//DATE//", os.date("%Y-%m-%d"))

    if lines[i]:find("//CURSOR//") then
      local indent = #(lines[i]:match("^(%s*)") or "")
      cursor_pos = { i, indent }
      lines[i] = lines[i]:gsub("//CURSOR//", "")
    end
  end

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  if cursor_pos then
    vim.api.nvim_win_set_cursor(0, cursor_pos)
  end
end

local template_group = vim.api.nvim_create_augroup("CodeTemplates", { clear = true })

vim.api.nvim_create_autocmd("BufNewFile", {
  group = template_group,
  pattern = "*.c",
  callback = function(args) load_template(args.buf, "skeleton.c") end,
})

vim.api.nvim_create_autocmd("BufNewFile", {
  group = template_group,
  pattern = { "*.s", "*.asm" },
  callback = function(args) load_template(args.buf, "skeleton.s") end,
})
