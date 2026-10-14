 local M = {}

function M.setup()
  require('base16-colorscheme').setup({
    base00 = '#131314',
    base01 = '#1f1f20',
    base02 = '#2a2a2a',
    base03 = '#8e9195',
    base04 = '#c4c6cb',
    base05 = '#e4e2e2',
    base06 = '#e4e2e2',
    base07 = '#e4e2e2',
    base08 = '#ffb4ab',
    base09 = '#d0c2d2',
    base0A = '#c4c6cb',
    base0B = '#bec7d3',
    base0C = '#d0c2d2',
    base0D = '#bec7d3',
    base0E = '#c4c6cb',
    base0F = '#e0e2e7',
  })

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  -- telescope.nvim
  hi('TelescopeNormal',         { fg = '#e4e2e2',          bg = '#131314' })
  hi('TelescopeBorder',         { fg = '#8e9195',             bg = '#131314' })
  hi('TelescopePromptNormal',   { fg = '#e4e2e2',          bg = '#131314' })
  hi('TelescopePromptBorder',   { fg = '#8e9195',             bg = '#131314' })
  hi('TelescopePromptPrefix',   { fg = '#bec7d3',             bg = '#131314' })
  hi('TelescopePromptCounter',  { fg = '#c4c6cb',  bg = '#131314' })
  hi('TelescopePromptTitle',    { fg = '#131314',             bg = '#bec7d3' })
  hi('TelescopePreviewTitle',   { fg = '#131314',             bg = '#c4c6cb' })
  hi('TelescopeResultsTitle',   { fg = '#131314',             bg = '#d0c2d2' })
  hi('TelescopeSelection',      { fg = '#e4e2e2',          bg = '#2a2a2a' })
  hi('TelescopeSelectionCaret', { fg = '#bec7d3',             bg = '#2a2a2a' })
  hi('TelescopeMatching',       { fg = '#bec7d3',             bold = true })

  -- mini.pick
  hi('MiniPickNormal',         { fg = '#e4e2e2',          bg = '#131314' })
  hi('MiniPickBorder',         { fg = '#8e9195',             bg = '#131314' })
  hi('MiniPickPrompt',   { fg = '#e4e2e2',          bg = '#131314' })
  hi('MiniPickPromptPrefix',   { fg = '#bec7d3',             bg = '#131314' })
  hi('MiniPickBorderText',    { fg = '#131314',             bg = '#bec7d3' })
  hi('MiniPickMatchCurrent',      { fg = '#e4e2e2',          bg = '#2a2a2a' })
  hi('MiniPickPromptCaret', { fg = '#bec7d3',             bg = '#2a2a2a' })
  hi('MiniPickMatchRanges',       { fg = '#bec7d3',             bold = true })
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
