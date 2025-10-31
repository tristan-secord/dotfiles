return {
  "johnseth97/codex.nvim",
  lazy = true,
  cmd = { 'Codex', 'CodexToggle' },
  keys = {
    {
      '<leader>cx',
      function() require('codex').toggle() end,
      desc = 'Toggle Codex popup',
    },
  },
  opts = {
    keymaps     = {
      toggle = nil,
      quit = '<C-q>',
    },
    border      = 'rounded',  -- Options: 'single', 'double', or 'rounded'
    width       = 0.8,
    height      = 0.8,
    model       = nil,        -- Optional: pass a string to use a specific model (e.g., 'o3-mini')
    autoinstall = true,
  },
  config = function()
    require('codex').status()
  end
}
