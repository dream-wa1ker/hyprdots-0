 local M = {}

function M.setup()
  require('base16-colorscheme').setup({
    base00 = '#2e3440',
    base01 = '#3b4252',
    base02 = '#444c5e',
    base03 = '#727d94',
    base04 = '#d8dee9',
    base05 = '#eceff4',
    base06 = '#eceff4',
    base07 = '#eceff4',
    base08 = '#bf616a',
    base09 = '#5e81ac',
    base0A = '#88c0d0',
    base0B = '#8fbcbb',
    base0C = '#96bbe9',
    base0D = '#96e9e7',
    base0E = '#96d6e9',
    base0F = '#bee8f4',
  })

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  -- telescope.nvim
  hi('TelescopeNormal',         { fg = '#eceff4',          bg = '#2e3440' })
  hi('TelescopeBorder',         { fg = '#727d94',             bg = '#2e3440' })
  hi('TelescopePromptNormal',   { fg = '#eceff4',          bg = '#2e3440' })
  hi('TelescopePromptBorder',   { fg = '#727d94',             bg = '#2e3440' })
  hi('TelescopePromptPrefix',   { fg = '#8fbcbb',             bg = '#2e3440' })
  hi('TelescopePromptCounter',  { fg = '#d8dee9',  bg = '#2e3440' })
  hi('TelescopePromptTitle',    { fg = '#2e3440',             bg = '#8fbcbb' })
  hi('TelescopePreviewTitle',   { fg = '#2e3440',             bg = '#88c0d0' })
  hi('TelescopeResultsTitle',   { fg = '#2e3440',             bg = '#5e81ac' })
  hi('TelescopeSelection',      { fg = '#eceff4',          bg = '#444c5e' })
  hi('TelescopeSelectionCaret', { fg = '#8fbcbb',             bg = '#444c5e' })
  hi('TelescopeMatching',       { fg = '#8fbcbb',             bold = true })

  -- mini.pick
  hi('MiniPickNormal',         { fg = '#eceff4',          bg = '#2e3440' })
  hi('MiniPickBorder',         { fg = '#727d94',             bg = '#2e3440' })
  hi('MiniPickPrompt',   { fg = '#eceff4',          bg = '#2e3440' })
  hi('MiniPickPromptPrefix',   { fg = '#8fbcbb',             bg = '#2e3440' })
  hi('MiniPickBorderText',    { fg = '#2e3440',             bg = '#8fbcbb' })
  hi('MiniPickMatchCurrent',      { fg = '#eceff4',          bg = '#444c5e' })
  hi('MiniPickPromptCaret', { fg = '#8fbcbb',             bg = '#444c5e' })
  hi('MiniPickMatchRanges',       { fg = '#8fbcbb',             bold = true })
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
