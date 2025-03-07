return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 300

    local wk = require("which-key")
    wk.add({
      {"<leader>c", group = "Copilot"},
      { "<leader>d", group = "dbee" },
    })
  end,
  opts = {
    triggers = {"<leader>"},
    preset = "modern",
  }
}

    -- wk.register({
    --   b = {
    --     name = "buffer"
    --   },
    --   c = {
    --     name = "Copilot"
    --   },
    --   e = {
    --     name = "LSP"
    --   }
    -- }, {prefix = "<leader>"})
    --
