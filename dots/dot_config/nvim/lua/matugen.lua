 local M = {}

function M.setup()
  require('base16-colorscheme').setup({
    base00 = '#1a1110',
    base01 = '#271d1c',
    base02 = '#322826',
    base03 = '#a08c89',
    base04 = '#d8c2be',
    base05 = '#f1dfdb',
    base06 = '#f1dfdb',
    base07 = '#f1dfdb',
    base08 = '#ffb4ab',
    base09 = '#ddc48c',
    base0A = '#e7bdb5',
    base0B = '#ffb4a6',
    base0C = '#ddc48c',
    base0D = '#ffb4a6',
    base0E = '#e7bdb5',
    base0F = '#ffdad4',
  })

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  -- telescope.nvim
  hi('TelescopeNormal',         { fg = '#f1dfdb',          bg = '#1a1110' })
  hi('TelescopeBorder',         { fg = '#a08c89',             bg = '#1a1110' })
  hi('TelescopePromptNormal',   { fg = '#f1dfdb',          bg = '#1a1110' })
  hi('TelescopePromptBorder',   { fg = '#a08c89',             bg = '#1a1110' })
  hi('TelescopePromptPrefix',   { fg = '#ffb4a6',             bg = '#1a1110' })
  hi('TelescopePromptCounter',  { fg = '#d8c2be',  bg = '#1a1110' })
  hi('TelescopePromptTitle',    { fg = '#1a1110',             bg = '#ffb4a6' })
  hi('TelescopePreviewTitle',   { fg = '#1a1110',             bg = '#e7bdb5' })
  hi('TelescopeResultsTitle',   { fg = '#1a1110',             bg = '#ddc48c' })
  hi('TelescopeSelection',      { fg = '#f1dfdb',          bg = '#322826' })
  hi('TelescopeSelectionCaret', { fg = '#ffb4a6',             bg = '#322826' })
  hi('TelescopeMatching',       { fg = '#ffb4a6',             bold = true })

  -- mini.pick
  hi('MiniPickNormal',         { fg = '#f1dfdb',          bg = '#1a1110' })
  hi('MiniPickBorder',         { fg = '#a08c89',             bg = '#1a1110' })
  hi('MiniPickPrompt',   { fg = '#f1dfdb',          bg = '#1a1110' })
  hi('MiniPickPromptPrefix',   { fg = '#ffb4a6',             bg = '#1a1110' })
  hi('MiniPickBorderText',    { fg = '#1a1110',             bg = '#ffb4a6' })
  hi('MiniPickMatchCurrent',      { fg = '#f1dfdb',          bg = '#322826' })
  hi('MiniPickPromptCaret', { fg = '#ffb4a6',             bg = '#322826' })
  hi('MiniPickMatchRanges',       { fg = '#ffb4a6',             bold = true })
end

-- Register a signal handler for SIGUSR1 (matugen updates).
-- The handler re-requires this module, which re-runs the code below, so the
-- previous handle is stopped first; otherwise handlers double on every signal.
if _G.__matugen_signal then
  _G.__matugen_signal:stop()
  _G.__matugen_signal:close()
end

local signal = vim.uv.new_signal()
_G.__matugen_signal = signal
signal:start(
  'sigusr1',
  vim.schedule_wrap(function()
    package.loaded['matugen'] = nil
    require('matugen').setup()
  end)
)

return M
