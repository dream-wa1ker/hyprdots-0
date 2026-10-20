 local M = {}

function M.setup()
  require('base16-colorscheme').setup({
    base00 = '#131314',
    base01 = '#1f1f20',
    base02 = '#2a2a2b',
    base03 = '#8f9195',
    base04 = '#c5c6cb',
    base05 = '#e4e2e2',
    base06 = '#e4e2e2',
    base07 = '#e4e2e2',
    base08 = '#ffb4ab',
    base09 = '#d3c1cf',
    base0A = '#c5c6cc',
    base0B = '#bfc7d3',
    base0C = '#d3c1cf',
    base0D = '#bfc7d3',
    base0E = '#c5c6cc',
    base0F = '#e1e2e8',
  })

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  -- telescope.nvim
  hi('TelescopeNormal',         { fg = '#e4e2e2',          bg = '#131314' })
  hi('TelescopeBorder',         { fg = '#8f9195',             bg = '#131314' })
  hi('TelescopePromptNormal',   { fg = '#e4e2e2',          bg = '#131314' })
  hi('TelescopePromptBorder',   { fg = '#8f9195',             bg = '#131314' })
  hi('TelescopePromptPrefix',   { fg = '#bfc7d3',             bg = '#131314' })
  hi('TelescopePromptCounter',  { fg = '#c5c6cb',  bg = '#131314' })
  hi('TelescopePromptTitle',    { fg = '#131314',             bg = '#bfc7d3' })
  hi('TelescopePreviewTitle',   { fg = '#131314',             bg = '#c5c6cc' })
  hi('TelescopeResultsTitle',   { fg = '#131314',             bg = '#d3c1cf' })
  hi('TelescopeSelection',      { fg = '#e4e2e2',          bg = '#2a2a2b' })
  hi('TelescopeSelectionCaret', { fg = '#bfc7d3',             bg = '#2a2a2b' })
  hi('TelescopeMatching',       { fg = '#bfc7d3',             bold = true })

  -- mini.pick
  hi('MiniPickNormal',         { fg = '#e4e2e2',          bg = '#131314' })
  hi('MiniPickBorder',         { fg = '#8f9195',             bg = '#131314' })
  hi('MiniPickPrompt',   { fg = '#e4e2e2',          bg = '#131314' })
  hi('MiniPickPromptPrefix',   { fg = '#bfc7d3',             bg = '#131314' })
  hi('MiniPickBorderText',    { fg = '#131314',             bg = '#bfc7d3' })
  hi('MiniPickMatchCurrent',      { fg = '#e4e2e2',          bg = '#2a2a2b' })
  hi('MiniPickPromptCaret', { fg = '#bfc7d3',             bg = '#2a2a2b' })
  hi('MiniPickMatchRanges',       { fg = '#bfc7d3',             bold = true })
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
