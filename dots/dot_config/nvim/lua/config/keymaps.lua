-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

-- Ctrl+S save (in any mode)
map({ "n", "i", "v", "x" }, "<C-s>", "<Cmd>w<CR>", { desc = "Save" })

-- Ctrl+X exit (in any mode)
map({ "n", "i", "v", "x" }, "<C-x>", "<Cmd>q<CR>", { desc = "Quit" })

-- Ctrl+Shift+S save and exit in any mode
map({ "n", "i", "v", "x" }, "<C-S-s>", "<Cmd>wq<CR>", { desc = "Save and Quit" })

-- Ctrl+Shift+X exit without saving in any mode
map({ "n", "i", "v", "x" }, "<C-S-x>", "<Cmd>q!<CR>", { desc = "Force Quit" })

-- Delete the current buffer, or use a count (e.g. 3<leader>bd) for a buffer number.
map("n", "<leader>bd", function()
  local count = vim.v.count
  Snacks.bufdelete(count > 0 and count or nil)
end, { desc = "Delete Buffer" })

-- Browse installed Unix manual pages, with exact section filters.
require("which-key").add({ { "<leader>m", group = "man pages" } })

map("n", "<leader>mm", function()
  Snacks.picker.man()
end, { desc = "All Man Pages" })

local man_sections = {
  ["1"] = "Commands",
  ["2"] = "System Calls",
  ["3"] = "Library Functions",
  ["4"] = "Devices",
  ["5"] = "File Formats",
  ["6"] = "Games",
  ["7"] = "Overviews and Conventions",
  ["8"] = "Administration",
  ["3type"] = "Types and Structs",
}

for section, description in pairs(man_sections) do
  local key = section == "3type" and "t" or section
  map("n", "<leader>m" .. key, function()
    Snacks.picker.man({
      title = "Man " .. section .. ": " .. description,
      transform = function(item)
        return item.section == section
      end,
    })
  end, { desc = "Man " .. section .. ": " .. description })
end

map("n", "<leader>mk", "<cmd>vertical Man<cr>", { desc = "Man Page for Word" })
