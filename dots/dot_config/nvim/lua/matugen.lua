 local M = {}

function M.setup()
  require('base16-colorscheme').setup({
    base00 = '#0f1513',
    base01 = '#1b211f',
    base02 = '#252b29',
    base03 = '#89938e',
    base04 = '#bfc9c4',
    base05 = '#dee4e0',
    base06 = '#dee4e0',
    base07 = '#dee4e0',
    base08 = '#ffb4ab',
    base09 = '#a9cbe3',
    base0A = '#b2ccc2',
    base0B = '#86d6bf',
    base0C = '#a9cbe3',
    base0D = '#86d6bf',
    base0E = '#b2ccc2',
    base0F = '#cde9de',
  })

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  -- telescope.nvim
  hi('TelescopeNormal',         { fg = '#dee4e0',          bg = '#0f1513' })
  hi('TelescopeBorder',         { fg = '#89938e',             bg = '#0f1513' })
  hi('TelescopePromptNormal',   { fg = '#dee4e0',          bg = '#0f1513' })
  hi('TelescopePromptBorder',   { fg = '#89938e',             bg = '#0f1513' })
  hi('TelescopePromptPrefix',   { fg = '#86d6bf',             bg = '#0f1513' })
  hi('TelescopePromptCounter',  { fg = '#bfc9c4',  bg = '#0f1513' })
  hi('TelescopePromptTitle',    { fg = '#0f1513',             bg = '#86d6bf' })
  hi('TelescopePreviewTitle',   { fg = '#0f1513',             bg = '#b2ccc2' })
  hi('TelescopeResultsTitle',   { fg = '#0f1513',             bg = '#a9cbe3' })
  hi('TelescopeSelection',      { fg = '#dee4e0',          bg = '#252b29' })
  hi('TelescopeSelectionCaret', { fg = '#86d6bf',             bg = '#252b29' })
  hi('TelescopeMatching',       { fg = '#86d6bf',             bold = true })

  -- mini.pick
  hi('MiniPickNormal',         { fg = '#dee4e0',          bg = '#0f1513' })
  hi('MiniPickBorder',         { fg = '#89938e',             bg = '#0f1513' })
  hi('MiniPickPrompt',   { fg = '#dee4e0',          bg = '#0f1513' })
  hi('MiniPickPromptPrefix',   { fg = '#86d6bf',             bg = '#0f1513' })
  hi('MiniPickBorderText',    { fg = '#0f1513',             bg = '#86d6bf' })
  hi('MiniPickMatchCurrent',      { fg = '#dee4e0',          bg = '#252b29' })
  hi('MiniPickPromptCaret', { fg = '#86d6bf',             bg = '#252b29' })
  hi('MiniPickMatchRanges',       { fg = '#86d6bf',             bold = true })
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
